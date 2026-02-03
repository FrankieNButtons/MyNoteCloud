# <center>Intro to Some Data Structure in BioInformatics</center>

## GWAS

### `VCF` (Variant Call Format, type: text)
#### Description
Variant Call Format (VCF) is a text file format used in bioinformatics for storing gene sequence variations. It consists of meta-information lines (starting with `##`), a header line (starting with `#CHROM`), and data lines describing each variant’s chromosome position, ID, reference and alternate alleles, quality score, filter status, and additional information.

#### Structure Example
```text
##fileformat=VCFv4.2
##INFO=<ID=DP,Number=1,Type=Integer,Description="Total Depth">
#CHROM  POS     ID        REF   ALT   QUAL FILTER INFO
chr1    878631  .         G     A     29.5 PASS   DP=14
```

#### From Command
```bash
bcftools view -v snps input.bcf \
  | bcftools filter -i 'QUAL>20 && DP>10' \
  > output.vcf
```

---

### `FASTA` (FASTA Format, type: text)
#### Description
FASTA is a simple text-based format for representing nucleotide or peptide sequences. Each record starts with a description line (beginning with `>`), followed by one or more lines of sequence data.

#### Structure Example
```text
>chr1 Human chromosome 1
AGCTTGCTAGCTAGCTTGACGATCGATCGT...
>chr2 Human chromosome 2
TTGACGTAGCTAGCTAGCATGCTAGCTAGC...
```

#### From Command
```bash
Simply from sequencing process
```

---

### `FASTQ` (FASTQ Format, type: text)
#### Description
FASTQ is a text-based format that stores both biological sequences and their corresponding quality scores. Each record consists of four lines: a sequence identifier (starting with `@`), the raw sequence letters, a separator line (starting with `+`), and quality scores.

#### Structure Example
```text
@SRR123456.1 length=100
GATCGGAAGAGCACACGTCTGAACTCCAGTCA...
+
!''*((((***+))%%%++)(%%%%).1***-+*''))**
```

#### From Command
```bash
samtools fastq input.bam > output.fastq
```

---

## Graph GWAS

### `GFA` (Graphical Fragment Assembly Format, type: text)
#### Description
GFA is a text format for describing sequence graphs used in assembly. It comprises records for segments (`S`), links (`L`), and paths (`P`), plus optional header lines (`H`), also there is walks (`W`) and junp (`J`) in the version over GFA1.1.

#### Structure Example
##### GFA1.0
```text
H	VN:Z:1.0
S	1	ATGCGT
S	2	GCTAGC
L	1	+	2	-	3M
P	chr1	1+,2-	1M,2M
```
##### GFA1.1+
```text
H	VN:Z:1.1

```
#### From Command
```bash
vg view -F GFA graph.vg > graph.gfa
```
=>
---

### `GAF` (Genome Alignment Format, type: text)
#### Description
GAF is a text format extending GFA to represent how reads align to a graph. Each record includes the query name, path of node IDs (with orientations), a CIGAR string, and optional tags.

#### Structure Example
```text
A00132:49:HCLTYDSXX:1:1101:1000:7200    300     150     298     -       GRCh38.chrX     156040895       41927053        41927201        148     148     60      tp:A:P  cm:i:20 s1:i:148        s2:i:0  dv:f:0  ql:B:i,150,150
```

#### From Command
```bash
vg view -a input.gam > output.gaf
```

---

### `BAM` (Binary Alignment/Map, type: binary)
#### Description
BAM is the binary, compressed equivalent of SAM, enabling random access and indexing. It stores alignment information including headers and alignment records.

#### Structure Example
```text
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:248956422
read1	0	chr1	10000	60	50M	*	0	0	ACGT...	IIII...
```

#### From Command
```bash
samtools view -bS input.sam | samtools sort -@ 4 -o sorted.bam
```

---

### `SAM` (Sequence Alignment/Map, type: text)
#### Description
SAM is a TAB-delimited text format for storing sequence alignment information. Each alignment line contains 11 mandatory fields, plus optional tags, following header lines (starting with `@`).

#### Structure Example
```text
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:248956422
read1	0	chr1	10000	60	50M	*	0	0	ACGT...	IIII...
```

#### From Command
```bash
bwa mem -t 8 reference.fa reads.fastq > aln.sam
```

---

### `GAM` (Graph Alignment/Mapping, type: Protobuf)
#### Description
GAM is a Protobuf-based format produced by VG for storing alignments of reads to a variation graph. It contains sequence, quality, and mapping path details.

#### Structure Example
```json
{"sequence":"GATCG...","quality":"IIII...","path":{"mapping":[{"position":{"node_id":1,"offset":0},"rank":1}]},"name":"read123"}
```

#### From Command
```bash
vg map -x graph.xg -g graph.gcsa -f reads.fastq > aln.gam
```

### `BIM`(, type: text)

---

## From `VG`

#### `vg` (Variation Graph, type: JSON)
##### Description
`vg` is the main command-line tool for constructing and manipulating variation graphs. It supports subcommands like `construct`, `index`, `map`, `pack`, and `call`.

##### Structure Example
```json
{"node":[{"id":1,"sequence":"A"},{"id":2,"sequence":"T"}],"edge":[{"from":1,"to":2,"from_start":false,"to_end":false}]}
```

##### From Command
```bash
vg construct -r reference.fa -v variants.vcf -t 4 > graph.vg
```

---

#### `xg` (XG Index, type: binary)
##### Description
XG is a binary index format for VG graphs that enables fast random access and path traversal within the graph.

##### Structure Example
```
nodes: 2500000
edges: 4999999
```

##### From Command
```bash
vg index -x graph.xg graph.vg
```