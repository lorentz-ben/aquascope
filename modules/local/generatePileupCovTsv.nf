process GENERATE_PILEUP_COV_TSV {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0' :
        'biocontainers/samtools:1.21--h50ea8bc_0' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.csi"), emit: csi, optional: true
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    input:
        tuple val(meta), path(resorted.bam)
        path(bedfile) 
        path fasta
    
    output:
        tuple val(meta), path('*.tsv'), emit: pos_cov_tsv
        tuple val(meta), path('*.png'), emit: img
    
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bedfile = "${meta.bedfile}"
    """
        samtools mpileup -aa -A -d 600000 -B -Q 0 -q 0 --reference $fasta -o pile.up $resorted.bam

        plotQC.py pile.up $bedfile

        mv pos-coverage-quality.tsv ${prefix}_pos-coverage-quality.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        END_VERSIONS 
    """
}