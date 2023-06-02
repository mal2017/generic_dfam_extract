localrules: dl_dfam, extract_from_dfam, collect_dfam, get_dfam_summary

# rule to download dfam curated database
rule dl_dfam:
    output:
        "results/dfam/Dfam.h5"
    params:
        h5 = config.get("DFAM_CURATED_H5")
    shell:
        "curl {params.h5} | gunzip -c > {output}"


rule extract_from_dfam:
    """
    https://github.com/Dfam-consortium/FamDB
    good info here about using famdb
    https://github.com/fansalon/TEconsensus
    dfam3.7 h5 works with the famdby.py that ships in the 'share' of repeatmasker conda package 4.1.5
    """
    input:
        h5 = "results/dfam/Dfam.h5"
    output:
        fa = temp("results/dfam/dfam_sequences.{rep_class}.fa")
    conda:
        "../envs/repeatmasker.yaml"
    params:
        famdb_args = config.get("FAMDB_ARGS")
    shell:
        """
        RPM_PATH=$(dirname $(which RepeatMasker)) &&
        FAMDBPY_PATH=$RPM_PATH/../share/RepeatMasker/famdb.py &&
        $FAMDBPY_PATH -i {input.h5} families \
            -f fasta_name --class {wildcards.rep_class} {params.famdb_args} > {output.fa}
        """

rule collect_dfam:
    input:
        expand("results/dfam/dfam_sequences.{rep_class}.fa", rep_class = config.get("DFAM_CLASSES"))
    output:
        fa ="results/dfam/dfam_sequences.fasta",
        lineages = "results/dfam/dfam_lineages.txt"
    conda:
        "../envs/samtools.yaml"
    shell:
        """
        cat {input} | cut -d " " -f 1 > {output.fa} &&
        grep --no-filename ">" {input} | sed 's/>//' | tr -s '' | tr ' ' '\t' | sort | uniq > {output.lineages}
        samtools faidx {output.fa}
        """


rule get_dfam_summary:
    """
    because above rule intentionally removes superfluous info from header
    """
    input:
        h5 = "results/dfam/Dfam.h5"
    output:
        summary = "results/dfam/dfam_summary.txt"
    params:
        famdb_args = config.get("FAMDB_ARGS")
    conda:
        "../envs/repeatmasker.yaml"
    shell:
        """
        RPM_PATH=$(dirname $(which RepeatMasker)) &&
        FAMDBPY_PATH=$RPM_PATH/../share/RepeatMasker/famdb.py &&
        $FAMDBPY_PATH -i {input.h5} families \
            -f summary {params.famdb_args} > {output.summary}
        """
        