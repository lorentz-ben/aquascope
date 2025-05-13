process GENERATE_COV_TSV {
    tag "$meta.id"
    label 'process_medium'

    //conda "${moduleDir}/environment.yml"
    //TODO update this once Andi sends over the container
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0' :
    //     'biocontainers/samtools:1.21--h50ea8bc_0' }"
    //container "${moduleDir}/aquascope.sif"
 
    

    input:
        tuple val(meta), path(pileup)
    
    output:
        tuple val(meta), path('*pos-coverage-quality.tsv'), emit: pos_cov_tsv
        tuple val(meta), path('*.png'), emit: img
        path  "versions.yml"          , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bedfile = "${meta.bedfile}"
    def bedfile_basename = "${bedfile}".tokenize('/').last()
    """
    if [[ ${bedfile} == https://* ]]; then
        wget -O $bedfile_basename $bedfile
    elif [[ -f ${bedfile} ]]; then
    # Local file, no need to download
        cp ${bedfile} ${bedfile_basename}
    else
        echo "Invalid bedfile: ${bedfile}"
        exit 1
    fi

        plotQC.py $pileup ${bedfile_basename}

        mv pos-coverage-quality.tsv ${prefix}_pos-coverage-quality.tsv

        for file in *.png; do mv "\${file}" "${prefix}_\${file}"; done 

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            ivar: \$(echo \$(ivar version 2>&1) | sed 's/^.*iVar version //; s/ .*\$//')
        END_VERSIONS
    """
}