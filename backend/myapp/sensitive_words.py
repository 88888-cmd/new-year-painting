import os
from django.conf import settings

SENSITIVE_WORDS = []

def load_sensitive_words():
    global SENSITIVE_WORDS
    try:
        file_path = settings.SENSITIVE_WORDS_PATH
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                SENSITIVE_WORDS = [line.strip() for line in f if line.strip()]
    except Exception as e:
        print(f"加载敏感词文件时异常: {e}")


def has_sensitive_words(text):
    if not text:
        return False
    for word in SENSITIVE_WORDS:
        if word in text:
            return True
    return False
