process GENERATE_PILEUP {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0' :
        'biocontainers/samtools:1.21--h50ea8bc_0' }"

    when:
    task.ext.when == null || task.ext.when

    input:
        tuple val(meta), path(bam)
        path fasta
    
    output:
        tuple val(meta), path('*.up'), emit: pileup
        path  "versions.yml"          , emit: versions
    
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bedfile = "${meta.bedfile}"
    """
        samtools mpileup -aa -A -d 600000 -B -Q 0 -q 0 --reference $fasta -o pile.up $bam

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        END_VERSIONS 
    """
}