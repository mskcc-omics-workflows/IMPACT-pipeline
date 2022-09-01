//
// Main workflow to kick off subworkflow: demultiplex.nf
//

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

WorkflowDemultiplex.initialise(params, log)
def List demux_inputs = WorkflowDemultiplex.inputFiles(params, log)
(runinfo, runparams, samplesheet, run_dir, casava_dir) = demux_inputs

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { DEMULTIPLEX } from '../../subworkflows/demultiplex/demultiplex.nf'

workflow RUN_DEMULTIPLEX {

    outfile = casava_dir + "/sample_fastq.csv"

    // Run demultiplex
    DEMULTIPLEX (runinfo, runparams, samplesheet, run_dir, casava_dir)

    // Post process
    post_process = DEMULTIPLEX.out.control_fastq
        .mix(
            DEMULTIPLEX.out.fastq,
            DEMULTIPLEX.out.undetermined
        )
        .map {
            meta, fastq -> [ meta.sample2project, fastq ]
        }
        .flatten()
        .toSortedList()
        .map { it ->
            WorkflowDemultiplex.fastqOrganization(casava_dir, it, outfile) }

    emit:
        outfile                         // channel: String: sample_fastq.csv with fastq locations
}



//workflow {
//    RUN_DEMULTIPLEX ()
//}