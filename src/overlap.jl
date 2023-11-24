function Sxyz(Rᵢ, Rⱼ, αᵢ, αⱼ, ℓᵢ, ℓⱼ, mᵢ, mⱼ, nᵢ, nⱼ)
    Rₚ = gaussianproduct(αᵢ, Rᵢ, αⱼ, Rⱼ, αᵢ + αⱼ)

    Sx = sᵢ(ℓᵢ, ℓⱼ, αᵢ + αⱼ, Rᵢ[1], Rⱼ[1], Rₚ[1])
    Sy = sᵢ(mᵢ, mⱼ, αᵢ + αⱼ, Rᵢ[2], Rⱼ[2], Rₚ[2])
    Sz = sᵢ(nᵢ, nⱼ, αᵢ + αⱼ, Rᵢ[3], Rⱼ[3], Rₚ[3])

    return Sx * Sy * Sz
end

function overlap(basis)
    n = length(basis)
    S = zeros(n, n)

    for i in 1:n, j in 1:n
        basisᵢ = basis[i]
        basisⱼ = basis[j]
        
        Rᵢ = basisᵢ.R
        Rⱼ = basisⱼ.R

        dist = distance(Rᵢ, Rⱼ)

        m = length(basisᵢ.α)
        p = length(basisⱼ.α)

        Sₐᵤₓ = zero(eltype(S))
        for k in 1:m, l in 1:p
            αᵢ = basisᵢ.α[k]
            αⱼ = basisⱼ.α[l]

            dᵢ = basisᵢ.d[k]
            dⱼ = basisⱼ.d[l]

            Nᵢ = basisᵢ.N[k]
            Nⱼ = basisⱼ.N[l]

            ℓᵢ, mᵢ, nᵢ = basisᵢ.ℓ, basisᵢ.m, basisᵢ.n
            ℓⱼ, mⱼ, nⱼ = basisⱼ.ℓ, basisⱼ.m, basisⱼ.n

            Sₐᵤₓ += (
                exp(-αᵢ * αⱼ * dist / (αᵢ + αⱼ)) *
                Nᵢ * Nⱼ * dᵢ * dⱼ * 
                Sxyz(Rᵢ, Rⱼ, αᵢ, αⱼ, ℓᵢ, ℓⱼ, mᵢ, mⱼ, nᵢ, nⱼ)
            )
        end
        S[i, j] += Sₐᵤₓ
    end

    return S
end
