//
// This file holds several functions specific to the 
// workflow/demultiplex/run_demultiplex.nf in the impact_pipeline pipeline
//
// NOTE: THIS CLASS HAS TO BE KICKED OFF IN ROOT DIR, OTHERWISE IT WILL NOT BE RECOGNIZED
class WorkflowDemultiplex {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        if (!params.run_dir) {
            log.error "Run directory not specified with e.g. '--run_dir 220726_M07206_0107_000000000-KGBL6'"
            System.exit(1)
        }
    }

    public static List inputFiles(params, log) {
        def output = []
        def inputs_list = [
            params.runinfo,
            params.runparams,
            params.samplesheet
        ]
        def path = ""
        for (param in inputs_list) { // check input files
            File file = new File(param)
            if (!file.exists()) { // if an input file is not specified, find the one in run dir
                path = params.run_dir + '/' + param
                File file_default = new File(path)
                if (file_default.exists()) {
                    output.add(path)
                } else {
                    param = param.capitcalize() // To deal with runParameters.xml and RunParameters.xml
                    path = params.run_dir + '/' + param
                    file_default = new File(path)
                    if (file_default.exists()) {
                        output.add(path)
                    } else {
                        log.error "Cannot find proper " + param
                        System.exit(1)
                    }
                }
            } else {
                output.add(path)
            }
        }
        output.add(params.run_dir) // Add run_dir
        output.add(outputDir(params, log)) // Add casava_dir
        return output
    }

    public static String outputDir(params, log) {
        String output = ""
        File full_path = new File(params.casava_dir)
        if (!full_path.exists()) { // if output dir is not specified, create one in run dir
            def path = params.run_dir + '/' + params.casava_dir
            File run_full_path = new File(path)
            if (run_full_path.exists()) {
                return path
            } else {
                log.info "Create output directory in run dir"
                run_full_path.mkdirs()
                return path
            }
        } else {
            return params.casava_dir
        }
    }

    public static String fastqOrganization(casava_dir, info_list, outfile) {
        // get rid of / in the casava_dir
        casava_dir = casava_dir.endsWith('/') ? casava_dir.substring(0, casava_dir.length() - 1) : casava_dir
        // define seperator to replace working dir to final dir for fastqs
        String seperator = casava_dir.split('/')[-1] + '/'

        // define output string
        def output = "sample,project,fastq_loc\n"

        // get sample to project from inputs and remove them from info_list
        // output undetermined fastq files and also remove them from info_list
        String[] sample2project_list = null
        def remove_list = []
        info_list.eachWithIndex { name, index -> 
            if (!name.startsWith('/')) {
                sample2project_list = name.split(";") 
                remove_list.add(index)
            }
            String fq = name
            if (fq.indexOf("Undetermined") != -1) {
                output += "undetermined,undetermined,"
                output += casava_dir + '/' + fq.split(seperator)[-1] + '\n'
                remove_list.add(index)
            }
        }
        for (i in remove_list.sort{-it}) {
            info_list.remove(i)
        }
        String[] fq_list = info_list

        for (s2p in sample2project_list) {
            def s2p_list = s2p.split(':')
            def sample = s2p_list[0]
            def project = s2p_list[1]
            def found = false
            for (fq in fq_list) {
                fq = fq.split(seperator)[-1]
                def fq_content = fq.split("/|_")
                if (project == fq_content[0] && sample == fq_content[1]) {
                    found = true
                    output += sample + ',' + project + ',' + casava_dir
                    output += '/' + fq + '\n'
                }
            }
            if (!found) {
                output += sample + ',' + project + ',\n'
            }
        }
        this.writeFile(outfile, output)
        return "DONE"
    }


    public static void writeFile(outfile, content) {
        if (!content) { // Avoid aync calls
            return
        }
        new File(outfile).withWriter('utf-8') {
            writer -> writer.writeLine content
        }
    }

    public static Integer checkFileSize(file_name) {
        File file = new File(file_name)
        return file.length()
    }
   
}
