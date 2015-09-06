## Image Reconstruction Source Code

### What does this package contain

1. Accelerated Proximal-Gradient Algorithms (NPG and NPGs)

The examples about this methods are under `npgEx` folder, where the code 
can reproduce the figures appear in our paper.  Note that our figures in 
paper are generated by `GNUplot` with the `*.data` files.

The algorithm implementations are under folder `npg`, which use the small
functions under `utils` folder.

2. Beam Hardening Correction Algorithms

All examples and data for our blind beam hardening correction method are
under folder `bhcEx` with algorithm implementations under `bhc`.


### How to Install

To install this package, first download the repository by running

    git clone https://github.com/isucsp/imgRecSrc.git

after downloading, from MATLAB change your current folder to `imgRecSrc/`.
Each time before running the methods from this package, first execute
`setupPath.m` to add necessary paths to the environment.

For X-ray CT examples, the projection and back projection operator
subroutines may be called from MATLAB.  Since they are written in `c`
language, to prepare MATLAB recognizable `MEX`
files, go to `imgRecSrc/prj` and compile the necessary files.  Instructions
on compiling the code are provided for both `UNIX` and `Windows`:

#### For `UNIX`

require: gcc, cuda toolkit (optional) and GPU (optional)

Execute `make cpu` to compile all cpu implementations.  If you have GPU
equipped, run `make gpu` to compile GPU implementation of the X-ray CT
projection operators.  The matlab code will automatically choose to run on
GPU if equipped.

If errors are reported while compiling the `*.c`/`*.cu` files under
`imgRecSrc/prj`, please edit the first few lines in
`imgRecSrc/prj/Makefile` to make sure the path for your `CUDA` installation
is correct.

#### For `Windows`





### References

Reconstruction of Nonnegative Sparse Signals Using Accelerated Proximal-Gradient Algorithms

Nesterov's Proximal-Gradient Algorithms for Reconstructing Nonnegative Signals with Sparse Transform Coefficients

