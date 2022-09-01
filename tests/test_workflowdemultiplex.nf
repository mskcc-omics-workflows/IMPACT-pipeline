//
// Testing for demultiplex workflow functions
//


WorkflowDemultiplex.initialise(params, log)
def List demux_inputs = WorkflowDemultiplex.inputFiles(params, log)
println demux_inputs

def fastq_list = []

def casava_dir = '/test_data/CASAVA_Processing/'
def meta = [:]
meta.sample2project = "PanHemePCP-180007:ArcherPanHemeV2-CLIN-20220132;M22-22222:ArcherPanHemeV2-CLIN-20220132;M22-09876:ArcherPanHemeV2-CLIN-20220132;M22-33333:ArcherV4-CLIN-20220134;Sureshot-180007:ArcherV4-CLIN-20220134;M22-67890:ArcherV4-CLIN-20220134;M22-11111:ArcherPanHemeV2-CLIN-20220132;M22-12345:ArcherPanHemeV2-CLIN-20220132;M22-54321:ArcherV4-CLIN-20220134;M22-44444:ArcherV4-CLIN-20220134"

def control_fastq = [ 
    meta,
    [
        "/full/path/CASAVA_Processing/ArcherPanHemeV2-CLIN-20220132/PanHemePCP-180007_S2_L001_R2_001.fastq.gz",
        "/full/path/CASAVA_Processing/ArcherPanHemeV2-CLIN-20220132/PanHemePCP-180007_S2_L001_R1_001.fastq.gz",
        "/full/path/CASAVA_Processing/ArcherPanHemeV2-CLIN-20220132/M22-11111_S7_L001_R2_001.fastq.gz",
        "/full/path/CASAVA_Processing/ArcherPanHemeV2-CLIN-20220132/M22-12345_S3_L001_R1_001.fastq.gz",
        "/full/path/CASAVA_Processing/ArcherV4-CLIN-20220134/Sureshot-180007_S1_L001_R1_001.fastq.gz",
        "/full/path/CASAVA_Processing/ArcherV4-CLIN-20220134/M22-44444_S10_L001_R2_001.fastq.gz"
    ]
]

def fastq = [
    meta,
    []
]

def undetermined = [
    meta,
    [
        "/full/path/CASAVA_Processing/Undetermined_S0_L001_R2_001.fastq.gz",
        "/full/path/CASAVA_Processing/Undetermined_S0_L001_R1_001.fastq.gz"
    ]
]

workflow {

    ch_fastq = Channel
        .from(
            control_fastq[1],
            fastq[1],
            undetermined[1],
            meta.sample2project
        )
        .flatten()
        .toSortedList()
        .map { it ->
            WorkflowDemultiplex.fastqOrganization(casava_dir, it, "sample_fastq.csv") }
        .view()


    length = WorkflowDemultiplex.checkFileSize("sample_fastq.csv")
    println length

}
// CMD:
// nextflow run tests/test_workflowdemultiplex.nf -profile docker --run_dir ~/project/pipeline-rewrite/220726_M07206_0107_000000000-KGBL6
