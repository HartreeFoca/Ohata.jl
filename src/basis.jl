abstract type Basis end

"""
```GaussianBasis``` is a *subtype* of ```Basis``` that stores the coefficients, exponents and angular momenta of the atomic orbital.
A basis set in theoretical and computational chemistry is a set of functions (called basis functions) that is used to represent the 
electronic wave function in the Hartree–Fock method or density-functional theory in order to turn the partial differential equations 
of the model into algebraic equations suitable for efficient implementation on a computer. The use of basis sets is equivalent to the 
use of an approximate resolution of the identity: the orbitals ``\\vert \\psi_{i} \\rangle`` are expanded within the basis set as a
linear combination of the basis functions ``\\vert \\psi_{i} \\rangle \\approx \\sum_{\\mu } c_{\\mu i} \\vert \\mu \\rangle``, 
where the expansion coefficients ``c_{\\mu i}`` are given by ``c_{\\mu i} = \\sum_{\\nu } \\langle \\mu \\vert \\nu \\rangle^{-1} 
\\langle \\nu \\vert \\psi_{i} \\rangle``. The basis set can either be composed of atomic orbitals (yielding the linear combination of 
atomic orbitals approach), which is the usual choice within the quantum chemistry community; plane waves which are typically used within 
the solid state community, or real-space approaches. Several types of atomic orbitals can be used: Gaussian-type orbitals, Slater-type 
orbitals, or numerical atomic orbitals. Out of the three, Gaussian-type orbitals are by far the most often used, as they allow efficient 
implementations of Post-Hartree–Fock methods. 
"""
struct GaussianBasis <: Basis
    R::SVector{Float64}
    α::SVector{Float64}
    d::SVector{Float64}
    ℓ::Int64
    m::Int64
    n::Int64
end

"""
The ```buildbasis``` method takes a ```Molecule``` as input and return for us an array of ```GaussianBasis``` types. For example, let's open the same 
```h2.xyz``` example. As a standard basis set, we use STO-3G data.

```julia
2 

H      -1.788131055      0.000000000     -4.028513155
H      -1.331928651      0.434077746     -3.639854078
```
We give the file as an input:

```julia
hydrogen = molecule("h2.xyz")
sto3g = buildbasis(hydrogen)
```
"""
function buildbasis(molecule::Molecule)
    sto3g = GaussianBasis[]

    for i in eachindex(molecule.atoms)
        number = molecule.numbers[i]
        coord = molecule.coords[i, :]

        for orbital in orbitalconfig(number)
            if orbital == "1s"
                push!(
                    sto3g,
                    GaussianBasis(coord, sto3g_α[number][1, :], sto3g_d[1, :], 0, 0, 0),
                )
            elseif orbital == "2s"
                push!(
                    sto3g,
                    GaussianBasis(coord, sto3g_α[number][2, :], sto3g_d[2, :], 0, 0, 0),
                )
            elseif orbital == "2p"
                push!(
                    sto3g,
                    GaussianBasis(coord, sto3g_α[number][2, :], sto3g_d[3, :], 1, 0, 0),
                )
                push!(
                    sto3g,
                    GaussianBasis(coord, sto3g_α[number][2, :], sto3g_d[3, :], 0, 1, 0),
                )
                push!(
                    sto3g,
                    GaussianBasis(coord, sto3g_α[number][2, :], sto3g_d[3, :], 0, 0, 1),
                )
            end
        end
    end

    return sto3g
end
