//
// Testing for subworkflow: create_meta.nf
//

include { DEMULTIPLEX } from '../demultiplex.nf'

File out_dir = new File(params.casava_dir)
if (!out_dir.exists()) {
    out_dir.mkdirs()
}


workflow {
    DEMULTIPLEX (
        file(params.runinfo),
        file(params.runparams),
        file(params.samplesheet),
        file(params.run_dir),
        file(out_dir)
    )
}