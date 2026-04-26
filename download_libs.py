#!/usr/bin/env python3
"""
Download script for LÖVE2D libraries for Ilha Obscura project.
Downloads essential libraries from their GitHub repositories.
"""

import urllib.request
import os
from pathlib import Path

# Define library URLs and target filenames
LIBRARIES = {
    'classic.lua': 'https://raw.githubusercontent.com/rxi/classic/master/classic.lua',
    'bump.lua': 'https://raw.githubusercontent.com/kikito/bump.lua/master/bump.lua',
    'push.lua': 'https://raw.githubusercontent.com/Ulydev/push/master/push.lua',
    'anim8.lua': 'https://raw.githubusercontent.com/kikito/anim8/master/anim8.lua',
    'flux.lua': 'https://raw.githubusercontent.com/rxi/flux/master/flux.lua'
}

def download_file(url, filename):
    """Download a file from URL to local filename."""
    try:
        print(f"Baixando {filename}...")
        urllib.request.urlretrieve(url, filename)
        print(f"✓ {filename} baixado com sucesso")
        return True
    except Exception as e:
        print(f"✗ Erro ao baixar {filename}: {e}")
        return False

def main():
    """Main download function."""
    # Create lib directory if it doesn't exist
    lib_dir = Path('lib')
    lib_dir.mkdir(exist_ok=True)
    
    print("Iniciando download das bibliotecas para Ilha Obscura...")
    print("=" * 50)
    
    success_count = 0
    total_count = len(LIBRARIES)
    
    for filename, url in LIBRARIES.items():
        filepath = lib_dir / filename
        if download_file(url, filepath):
            success_count += 1
    
    print("=" * 50)
    print(f"Download concluído: {success_count}/{total_count} bibliotecas baixadas")
    
    if success_count == total_count:
        print("✓ Todas as bibliotecas foram baixadas com sucesso!")
    else:
        print("✗ Algumas bibliotecas não puderam ser baixadas.")
        print("Verifique sua conexão com a internet e tente novamente.")

if __name__ == "__main__":
    main()
