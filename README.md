# reborn
CSE Project for SEU19s

1. `cpu/m1afinal`: CPU Design
2. `krill`: C-Compiler
3. `linker`: Linker Design
4. `mias`: MInisys ASsembler
5. `mide`: Minisys IDE
6. `mua`: Minisys Uart Assist

---

NOTE: For convinience, I gave all the permission to you. However, developing on `main` branch is not permitted, please checkout to your branch and start your job.

If you are going to submit a feature to the `main` branch, please:

1. Test your code carefully.
2. You can either:
  1. Add a readme file, to illustrate what you have implemented, and push to your **dev branch**.
  2. or, New Pull Request. 

We will check your code depend on what you have illustrated, and merge it to the `main` branch.

## Todo List

> The detailed Todo List can be found in `roadmap.md`

Hardware:

- [x] CPU Design: Minisys-1
- [x] CPU Design: Minisys-1A
- [x] Memory
- [x] Interface

> Note: In hardware part, I am going to support basic SIMD support to the CPU. The basic logic is similar to `<xmminstr>`
> 
> Refer to: [SIMD Extension](https://learn.microsoft.com/en-us/cpp/parallel/openmp/openmp-simd?view=msvc-170), [ARM Intrinscs](https://learn.microsoft.com/en-us/cpp/parallel/openmp/openmp-simd?view=msvc-170)

Software:


- [x] `as`
- [ ] `cc`
- [ ] BIOS
- [ ] `ld`
- [x] IDE- based on vim/vscode/... (or lsp support?)

Integration:

...




