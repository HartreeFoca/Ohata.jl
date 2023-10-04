function θ(l, lA, lB, PA, PB, r, g)
    θ = cₖ(l, lA, lB, PA, PB)
    θ *= factorial(l) * g^(r - l)
    θ /= factorial(r) * factorial(l - 2 * r)

    return θ
end

function gi(l, lp, r, rp, i, lA, lB, Ai, Bi, Pi, gP, lC, lD, Ci, Di, Qi, gQ)
    δ = 1 / (4 * gP) + 1 / (4 * gQ)

    gi = (-1.0)^l
    gi *= θ(l, lA, lB, Pi - Ai, Pi - Bi, r, gP) * θ(lp, lC, lD, Qi - Ci, Qi - Di, rp, gQ)
    gi *= (-1.0)^i * (2 * δ)^(2 * (r + rp))
    gi *= factorial(l + lp - 2 * r - 2 * rp) * δ^i
    gi *= (Pi - Qi)^(l + lp - 2 * (r + rp + i))
    gi /= (4 * δ)^(l + lp) * factorial(i)
    gi /= factorial(l + lp - 2 * (r + rp + i))

    return gi
end

function Gxyz(lA, mA, nA, lB, mB, nB, lC, mC, nC, lD, mD, nD, a, b, c, d, RA, RB, RC, RD)
    gP = a + b
    gQ = c + d

    δ = 1 / (4 * gP) + 1 / (4 * gQ)

    RP = gaussianproduct(a, RA, b, RB, gP)
    RQ = gaussianproduct(c, RC, d, RD, gQ)

    AB = distance(RA, RB)
    CD = distance(RC, RD)
    PQ = distance(RP, RQ)

    Gxyz = 0.0

    for l = 0:(lA+lB)
        for r = 0:trunc(Int64, l / 2)
            for lp = 0:(lC+lD)
                for rp = 0:trunc(Int64, lp / 2)
                    for i = 0:trunc(Int64, (l + lp - 2 * r - 2 * rp) / 2)
                        gx = gi(
                            l,
                            lp,
                            r,
                            rp,
                            i,
                            lA,
                            lB,
                            RA[1],
                            RB[1],
                            RP[1],
                            gP,
                            lC,
                            lD,
                            RC[1],
                            RD[1],
                            RQ[1],
                            gQ,
                        )

                        for m = 0:(mA+mB)
                            for s = 0:trunc(Int64, m / 2)
                                for mp = 0:(mC+mD)
                                    for sp = 0:trunc(Int64, mp / 2)
                                        for j =
                                            0:trunc(Int64, (m + mp - 2 * s - 2 * sp) / 2)
                                            gy = gi(
                                                m,
                                                mp,
                                                s,
                                                sp,
                                                j,
                                                mA,
                                                mB,
                                                RA[2],
                                                RB[2],
                                                RP[2],
                                                gP,
                                                mC,
                                                mD,
                                                RC[2],
                                                RD[2],
                                                RQ[2],
                                                gQ,
                                            )

                                            for n = 0:(nA+nB)
                                                for t = 0:trunc(Int64, n / 2)
                                                    for np = 0:(nC+nD)
                                                        for tp = 0:trunc(Int64, np / 2)
                                                            for k =
                                                                0:trunc(
                                                                Int64,
                                                                (n + np - 2 * t - 2 * tp) /
                                                                2,
                                                            )
                                                                gz = gi(
                                                                    n,
                                                                    np,
                                                                    t,
                                                                    tp,
                                                                    k,
                                                                    nA,
                                                                    nB,
                                                                    RA[3],
                                                                    RB[3],
                                                                    RP[3],
                                                                    gP,
                                                                    nC,
                                                                    nD,
                                                                    RC[3],
                                                                    RD[3],
                                                                    RQ[3],
                                                                    gQ,
                                                                )

                                                                ν =
                                                                    l +
                                                                    lp +
                                                                    m +
                                                                    mp +
                                                                    n +
                                                                    np -
                                                                    2 * (
                                                                        r +
                                                                        rp +
                                                                        s +
                                                                        sp +
                                                                        t +
                                                                        tp
                                                                    ) - (i + j + k)
                                                                F = boys(ν, PQ / (4 * δ))
                                                                Gxyz += gx * gy * gz * F
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    Gxyz *= (2 * π^2) / (gP * gQ)
    Gxyz *= sqrt(π / (gP + gQ))
    Gxyz *= exp(-(a * b * AB) / gP)
    Gxyz *= exp(-(c * d * CD) / gQ)

    Na = normalization(a, lA, mA, nA)
    Nb = normalization(b, lB, mB, nB)
    Nc = normalization(c, lC, mC, nC)
    Nd = normalization(d, lD, mD, nD)

    Gxyz *= Na * Nb * Nc * Nd

    return Gxyz
end

function repulsion(basis, molecule::Molecule)
    n = length(basis)
    G = zeros(n, n, n, n)

    Ntei = 0
    
    for i in 1:n, j in 1:n, t in 1:n, u in 1:n
        basisᵢ = basis[i]
        basisⱼ = basis[j]
        basisₜ = basis[t]
        basisᵤ = basis[u]
        
        Rᵢ = basisᵢ.R
        Rⱼ = basisⱼ.R
        Rₜ = basisₜ.R
        Rᵤ = basisᵤ.R

        m = length(basisᵢ.α)
        p = length(basisⱼ.α)
        q = length(basisₜ.α)
        r = length(basisᵤ.α)

        Ntei += 1

        for k in 1:m, l in 1:p, s in 1:q, v in 1:r
            αᵢ = basisᵢ.α[k]
            αⱼ = basisⱼ.α[l]
            αₜ = basisₜ.α[s]
            αᵤ = basisᵤ.α[v]

            dᵢ = basisᵢ.d[k]
            dⱼ = basisⱼ.d[l]
            dₜ = basisₜ.d[s]
            dᵤ = basisᵤ.d[v]

            ℓᵢ, mᵢ, nᵢ = basisᵢ.ℓ, basisᵢ.m, basisᵢ.n
            ℓⱼ, mⱼ, nⱼ = basisⱼ.ℓ, basisⱼ.m, basisⱼ.n
            ℓₜ, mₜ, nₜ = basisₜ.ℓ, basisₜ.m, basisₜ.n
            ℓᵤ, mᵤ, nᵤ = basisᵤ.ℓ, basisᵤ.m, basisᵤ.n

            tei = dᵢ * dⱼ * dₜ * dᵤ
            tei *= Gxyz(ℓᵢ, mᵢ, nᵢ, ℓⱼ, mⱼ, nⱼ, ℓₜ, mₜ, nₜ, ℓᵤ, mᵤ, nᵤ, αᵢ, αⱼ, αₜ, αᵤ, Rᵢ, Rⱼ, Rₜ, Rᵤ)
            
            G[i, j, t, u] += tei
        end
    end

    return G
end