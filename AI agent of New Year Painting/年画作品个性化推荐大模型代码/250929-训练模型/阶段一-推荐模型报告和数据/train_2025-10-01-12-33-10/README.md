---
library_name: peft
license: other
base_model: /root/autodl-tmp/qwen3-4B-Instruct
tags:
- base_model:adapter:/root/autodl-tmp/qwen3-4B-Instruct
- llama-factory
- lora
- transformers
pipeline_tag: text-generation
model-index:
- name: train_2025-10-01-12-33-10
  results: []
---

<!-- This model card has been generated automatically according to the information the Trainer had access to. You
should probably proofread and complete it, then remove this comment. -->

# train_2025-10-01-12-33-10

This model is a fine-tuned version of [/root/autodl-tmp/qwen3-4B-Instruct](https://huggingface.co//root/autodl-tmp/qwen3-4B-Instruct) on the nianhua_recommendation_train dataset.

## Model description

More information needed

## Intended uses & limitations

More information needed

## Training and evaluation data

More information needed

## Training procedure

### Training hyperparameters

The following hyperparameters were used during training:
- learning_rate: 5e-05
- train_batch_size: 8
- eval_batch_size: 8
- seed: 42
- gradient_accumulation_steps: 8
- total_train_batch_size: 64
- optimizer: Use OptimizerNames.ADAMW_TORCH with betas=(0.9,0.999) and epsilon=1e-08 and optimizer_args=No additional optimizer arguments
- lr_scheduler_type: cosine
- num_epochs: 3.0

### Training results



### Framework versions

- PEFT 0.17.1
- Transformers 4.56.1
- Pytorch 2.8.0+cu128
- Datasets 4.0.0
- Tokenizers 0.22.1