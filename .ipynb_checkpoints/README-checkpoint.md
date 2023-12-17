# Genomic Operations Script

## Overview

This Bash script, named `merge_vcfs.sh`, is designed to perform genomic operations using the `bcftools` utility. The script facilitates the merging of samples, annotation of genomic regions, and the creation of a Variant Call Format (VCF) file containing specific samples.

## Script Usage

```bash
./merge_vcfs.sh <samplesPathFile> <regionFile> <refGenome> <sampleMetadata> <outputFile> [sampleIDs]
```

### Description:

- `<samplesPathFile>`: Path to the file containing a list of sample paths.
- `<regionFile>`: Path to the genomic region file.
- `<refGenome>`: Path to the reference genome file.
- `<sampleMetadata>`: Path to the sample metadata file.
- `<outputFile>`: Path to the output VCF file.
- `[sampleIDs]` (Optional): Comma-separated list of specific sample IDs. If not provided, all proband IDs will be used.

### Example:

```bash
./merge_vcfs.sh samples.txt regions.bed reference.fa metadata.csv output.vcf
```

### Sample Metadata Format:

The sample metadata file (`metadata.csv`) is expected to have the following format:

```plaintext
ID, family_id, fam_relation, fam_relation_description, #_chrom, Karyotype, Phenotype, source
AS22WG001, 10726, 0
AS22WG002, 10726, 2
AS22WG003, 10726, 1
```

Make sure the file is tab-separated.
.

## Additional Information:

- The script utilizes the `bcftools` utility, so it is necessary to have it installed and accessible in your environment.
- The script checks the exit code of each command and exits if an error occurs.
- Temporary files (`tmp.vcf.gz` and `norm_tmp.vcf.gz`) are created during the script execution and are removed at the end.
- The genomic region annotation is performed using the provided `regionFile` and associated headers.
- The final VCF file (`output.vcf`) contains the specified samples or all proband IDs if not provided.

Feel free to adapt the script to your specific genomic data and analysis requirements.