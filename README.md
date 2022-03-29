# IS-project-2020.2

## Projeto ASM x86, CIn - UFPE

<p align="left">
    <img alt="Operação" src=".github/showGif.gif" width = "100%">
</p>

### How to run

#### Windows

Follow the instructions: https://dev.to/kailanefelix/executando-assembly-com-qemu-no-wsl-2i9j

#### Linux/Mac

- Install Nasm (Assembler)

```bash
sudo apt install nasm
```

- Install QEMU (Emulator)

```bash
sudo apt install qemu qemu-system-x86
```

- Compile (Using MakeFile)

```bash
make
```

#### Obs:

- To compile and open a singular file:

```bash
nasm -f bin input.asm -o output.bin
qemu-system-i386 output.bin
```

Where input.asm is the file.
