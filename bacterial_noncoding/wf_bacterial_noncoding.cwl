#!/usr/bin/env cwl-runner
label: "Non-Coding Bacterial Genes"
cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement

inputs:
  go: 
        type: boolean[]
  asn_cache: Directory
  seqids: File
  16s_blastdb_dir: Directory
  23s_blastdb_dir: Directory
  model_path: File
  rfam_amendments: File
  rfam_stockholm: File
  taxon_db: File

outputs:
  # asncache:
  #   type: Directory
  #   outputSource: bacterial_noncoding_16S/asncache
  annotations_5s:
    type: File
    outputSource: annot_ribo_operons/output_5S
  annotations_16s:
    type: File
    outputSource: annot_ribo_operons/output_16S
  annotations_23s:
    type: File
    outputSource: annot_ribo_operons/output_23S
    
steps:
  bacterial_noncoding_5S:
    run: wf_gcmsearch.cwl
    in:
      asn_cache: asn_cache
      seqids: seqids
      model_path: model_path
      rfam_amendments: rfam_amendments
      rfam_stockholm: rfam_stockholm
      taxon_db: taxon_db
    out: [ annots ]

  bacterial_noncoding_16S:
    run: wf_blastn.cwl
    in:
      asn_cache: asn_cache
      seqids: seqids
      blastdb_dir: 16s_blastdb_dir
      blastdb:
        default: blastdb
      product_name: 
        default: "16S ribosomal RNA"
      outname:
        default: annotations_16s.asn
    out: [annotations]

  bacterial_noncoding_23S:
    run: wf_blastn.cwl
    in:
      asn_cache: asn_cache
      seqids: seqids
      blastdb_dir: 23s_blastdb_dir
      blastdb:
        default: Ribosom23S
      product_name: 
        default: "23S ribosomal RNA"
      outname:
        default: annotations_23s.asn
    out: [annotations]

  annot_ribo_operons:
    run: ../progs/annot_ribo_operons.cwl
    in:
      input_5S: bacterial_noncoding_5S/annots
      input_16S: bacterial_noncoding_16S/annotations
      input_23S: bacterial_noncoding_23S/annotations
    out: [output_5S, output_16S, output_23S]
    
