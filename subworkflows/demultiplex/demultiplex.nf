//
// Demultplexing
//

include { PRE_BCL2FASTQ } from '../../modules/msk-tools/pre_bcl2fastq/main.nf'
include { BCL2FASTQ } from '../../modules/msk-tools/bcl2fastq2/main.nf'

workflow DEMULTIPLEX {

    take:
        runinfo                 // channel: [mandatory] runinfo
        runparams               // channel: [mandatory] runparams
        samplesheet             // channel: [mandatory] samplesheet
        run_dir                 // channel: [mandatory] run_dir
        casava_dir              // channel: [mandatory] casava_dir

    main:
        PRE_BCL2FASTQ ( [runinfo, runparams, samplesheet] )
            .meta_file
            .splitCsv ( header:true, sep:',')
            .map { create_meta_channel(it) }
            .set { ch_meta_obj }

        ch_meta_obj
            .map { meta -> 
                [ meta, samplesheet, run_dir, casava_dir ] }
            .set{ ch_meta }
  
        BCL2FASTQ ( ch_meta )


    emit:
        control_fastq = BCL2FASTQ.out.control_fastq     // channel: [val(meta), path("**/**[!Undetermined]_S*_R?_00?.fastq.gz"), optional
        fastq = BCL2FASTQ.out.fastq                     // channel: [val(meta), path("**/**/**[!Undetermined]_S*_R?_00?.fastq.gz")
        undetermined = BCL2FASTQ.out.undetermined       // channel: [val(meta), path("Undetermined_S0*_R?_00?.fastq.gz")
}

def create_meta_channel(LinkedHashMap meta_obj) {
    def meta = [:] //construction of meta map
    meta.id = meta_obj.flowcell
    meta.run = meta_obj.run_name
    meta.pool = meta_obj.exp_name

    meta.base_mask = meta_obj.base_mask.replaceAll(";", ",")
    meta.no_lane_split = ""
    if ( !meta_obj.no_lane_split.empty ) {
        meta.no_lane_split = meta_obj.no_lane_split
    }
    meta.mismatches = meta_obj.mismatch
    meta.ignore_map = [
        bcls: true,
        filter: true,
        positions: true,
        controls: true
    ]
    // For postprocess of demux
    meta.sample2project = meta_obj.sample2project
    return meta
}