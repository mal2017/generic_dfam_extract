# GENERIC_DFAM_TES

generic workflow for downloading and extracting TEs from DFAM.

## Usage

```bash
snakemake --use-conda --cores <n> 
```

## Output

Expects a config containing:
    DFAM_H5 (a uri for a DFAM famdb formatted h5 file, can be remote)
    DFAM_ARGS (-ad by default, to retrieve ancestor and descendant repeats)
    DFAM_CLASSES (see note below)

Yields

The requested repeat sequences: `results/dfam/dfam_sequences.fasta`
`results/dfam/dfam_summary.txt`

Info about lineages from fasta header:`results/dfam/dfam_lineages.txt`

## Notes

### HPC

By default all rules run locally. This is because downloads are generally faster on login nodes (at least where I am) and the other steps
are just extraction from databases with minimal resource requirements.

### Repeat classes

The allowed nomenclature is poorly documented ([ref1](https://github.com/Dfam-consortium/FamDB) and [ref2](https://www.repeatmasker.org/webrepeatmaskerhelp.html)). But there are classes
of repeat that are included in a full DFAM dump that are probably not what users want, such as simple repeats.

By default this pipeline retrieves sequences with RepeatMasker classes SINE, LINE, LTR, RC, and DNA. This is nonredundant for mus musculus
and yields 1237 TEs with DFAM 3.7.

Subsets of TEs (or other repeat types) can be specified by adding the following to the config.

```
DFAM_CLASSES: [LINE, SINE, ...etc...]
```
