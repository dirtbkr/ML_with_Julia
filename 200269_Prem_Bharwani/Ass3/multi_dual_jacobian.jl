### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ f0149a28-4cd8-4d85-a60f-6a6821d02563
begin
	using ForwardDiff
	using StaticArrays
	import Base: +, *, >, ==,log,sin,cos
end

# ╔═╡ 86e8bc44-c3ca-4d59-be1f-d5d6e3891bca
using Zygote

# ╔═╡ 664f3378-77e5-43f2-adcf-74d567da2725
md"""
### ML\_With\_Julia project assignment submission 

##### Index :

##### - MultiDual definition and functions 

##### - Implementation of convert and promote_rule

##### - Implementation of Jacobian for any arbitrary function and input vector

##### _Prem Bharwani_
"""

# ╔═╡ 2cb10bd2-9d8b-47f1-a442-2fed03be63e3
md"""
Basic Imports 
"""

# ╔═╡ d11a6c5b-fabd-4863-80a3-22566dc590f1
md"""
##### MultiDual definition
"""

# ╔═╡ cd8c69bf-cb8d-4a65-b273-f2e0e2daec37
struct MultiDual{N,T} <: Number# N : size of vector & T : datatype of the vector
	val::T
	derivs::SVector{N,T}
end

# ╔═╡ d4b7a354-9fac-4fa7-b7d8-0d5adc230123
md"""
##### MultiDual Function Definitions
"""

# ╔═╡ 56ff2c52-9965-4f76-8605-8d3895873ebb
begin
	# Normal addition : all the components are simply added
	function Base.:+(f::MultiDual{N,T} , g::MultiDual{N,T}) where {N,T}
		return MultiDual(f.val+g.val , f.derivs+g.derivs)
	end

	# Multiplication : Val is multiplied directly , Derivs follow the product rule
	function Base.:*(f::MultiDual{N,T} , g::MultiDual{N,T}) where {N,T}
		return MultiDual(f.val*g.val , f.derivs*g.val + f.val*g.derivs )
	end
	# Divide : Val is divided directly , Derivs follow the quotient rule
	function Base.:/(f::MultiDual{N,T} , g::MultiDual{N,T}) where {N,T}
		return MultiDual(f.val/g.val , (f.derivs*g.val - f.val*g.derivs)/(g.val^2) )
	end
# 	Less than check [doesn't work with numbers]
	function Base.:isless(f::MultiDual{N,T} , g::MultiDual{N,T}) where {N,T}
		return f.val<g.val
	end
# 	Equal check
	function Base.:(==)(f::MultiDual{N,T} , g::MultiDual{N,T}) where {N,T}
		return f.val==g.val
	end
# 	Abs
	Base.:abs(f::MultiDual{N,T}) where {N,T} = MultiDual(abs(f.val),f.derivs)
# 	sin & cos
	Base.:sin(f::MultiDual{N,T}) where {N,T} = MultiDual(sin(f.val),f.derivs*cos(f.val))
	Base.:cos(f::MultiDual{N,T}) where {N,T} = MultiDual(cos(f.val),f.derivs*sin(-f.val))
# 	^
	Base.:(^)(f::MultiDual{N,T},x::Real) where {N,T} = MultiDual(f.val^x ,x*(f.val^(x-1))*f.derivs)
# 	log
	Base.:log(f::MultiDual{N,T}) where {N,T<:Real} = MultiDual(log(f.val) , f.derivs/f.val)
# 	exp
	Base.:exp(f::MultiDual{N,T}) where {N,T} = MultiDual( exp(f.val) , exp(f.val)*f.derivs )
end

# ╔═╡ fdbb17b2-5127-4893-8064-b76eac713c5d
md"""
Defining some MultiDuals for testing
"""

# ╔═╡ 0dfd2d12-8259-4a01-b500-0d6aaa75c708
begin
	a = MultiDual(4.0,SVector(1.0,1.0))
	b = MultiDual(2.0,SVector(0.0,1.0))
	c = MultiDual(4,SVector(0,1))
	d = MultiDual(-6,SVector(0,1))
end

# ╔═╡ b88947e5-c28f-481d-8e25-807516a02a49
md"""
##### Convert function definition
"""

# ╔═╡ d4519448-75c4-4dc6-a153-133a99d6729a
Base.convert(::Type{MultiDual{N, T}}, x::T) where {N, T<:Real} =
  MultiDual(x, zeros(SVector{N, T}))

# ╔═╡ 4df3388a-d58f-47f5-b795-02cf150ac7a4
md"""
##### promote_rule definition
"""

# ╔═╡ 4eb0419d-87fa-4205-8eef-ae6f462bd9eb
begin
	import Base:promote_rule
	Base.promote_rule(::Type{MultiDual{N, T}}, ::Type{T}) where {N, T<:Real} =  MultiDual{N, T}
end

# ╔═╡ ee75ca1a-12bc-4f14-8601-d4aa7de3fc5e
md"""
displaying the working of functions with MultiDual , Numbers
"""

# ╔═╡ dcf46f04-96e6-4524-ba49-dba2f353c1ba
@show +(a,3.0)

# ╔═╡ dfac7b20-3ea3-4f8c-833d-4958c464ceec
@show *(b,2.0)

# ╔═╡ 5d2874b0-4826-4dfe-8db5-384ec291001f
@show /(b,2.0)

# ╔═╡ 494319c8-0670-4f7f-a5bf-4306f48cb373
@show a==4.0

# ╔═╡ e5ce855e-8768-4b50-b526-d9db9dd04ed5
@show abs(d)

# ╔═╡ b5ce02d6-bffd-411e-a42d-a364cf47197f
@show sin(a)

# ╔═╡ f27e4e55-dabe-48c1-b4e1-55d44c636fcd
@show a^1.5

# ╔═╡ ab369017-eade-476d-867d-6aac818f6d45
@show log(a)

# ╔═╡ bbc37085-470d-4234-89d4-a0635fe47192
@show exp(a)

# ╔═╡ 15efa167-17ee-4f13-8584-f5a68d01fc67
@show <(promote(b,1.0)...)

# ╔═╡ 801bec8f-108b-411b-92e5-5c13f2a52f6c
md"""
##### Defining Jacobian
"""

# ╔═╡ 46b2ff4e-5055-48bf-a425-84768ba6d646
md"""
Define your function , and the input vector below to get the jacobian
"""

# ╔═╡ a6f4ba5b-465c-4a79-b421-15b85744ebdd
g(x,y,z) = [x^2+y^2 , x^3+y^3 , z^3]

# ╔═╡ eed7e56c-8e14-4f99-b692-f23bb48eb0c8
inp = [1,2,3]

# ╔═╡ b18786b4-38ba-47ad-83c1-4952d4fa085c
md"""
Below is an example how we will take individual components from the function output to calculate its gradients
"""

# ╔═╡ f69d1742-24b2-489c-9bbf-068c30cf6fd3
g(inp...)[1]

# ╔═╡ a9cf3d23-36d5-4d07-a3d2-462423dbc953
md"""
For example , Below we will find out the gradient wrt all the components of `f1`
"""

# ╔═╡ 25bc1007-cb4d-4cbe-972c-06ebb962c81c
grad_f1 = gradient(inp->g(inp...)[1],inp)

# ╔═╡ 25f790c3-a12b-43ab-8cb8-14057504f55a
grad_f1[1]

# ╔═╡ b59a4849-dd1d-4ecc-bfc9-9ff482b3f175
md"""
Below is the jacobian function which takes in the function definitions and the input vector to produce the jacobian matrix
"""

# ╔═╡ 0045d2f1-7b0e-43c5-84d2-d71cbefa04f2
function jacobian(in_vector , fun::Function )
	n=length(in_vector)
	ans = zeros((n,n))
	for j =1:n
		g = gradient(in_vector->fun(in_vector...)[j],in_vector)
		grad = g[1]
		for ii = 1:n
			ans[j,ii]=grad[ii]
		end
	end
	return ans
end


# ╔═╡ cef01ad3-667d-4c2e-a6d5-3003d36cf0e3
md"""
Let us use the handwritten jacobian function below
"""

# ╔═╡ b89653bf-6dfc-4886-afe9-9ac4a67387ea
jacobian(inp,g)

# ╔═╡ e420f761-5f39-4e67-a3a1-8706631a0aa1
md"""
Lets compare the results with the Jacobian function from the ForwardDiff library to verify our results
"""

# ╔═╡ 7182a84a-e86e-44dc-9bf0-55a044e20346
ForwardDiff.jacobian(x->g(x...),inp)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
ForwardDiff = "~0.10.18"
StaticArrays = "~1.2.6"
Zygote = "~0.6.16"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ChainRules]]
deps = ["ChainRulesCore", "Compat", "LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "dabb81719f820cddd6df4916194d44f1fe282bd1"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "0.8.22"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dcc25ff085cf548bc8befad5ce048391a7c07d40"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.11"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "214c3fcac57755cfda163d91c58893a8723f93e9"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.0.2"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "25b9cc23ba3303de0ad2eac03f840de9104c9253"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.0"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "e2af66012e08966366a43251e1fd421522908be6"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.18"

[[IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "95215cd0076a150ef46ff7928892bc341864c73c"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.3"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "6a8a2a625ab0dea913aba95c11370589e0239ff0"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.6"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a50550fa3164a8c46747e62063b4d774ac1bcf49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.5.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "a43a7b58a6e7dc933b2fa2e0ca653ccf8bb8fd0e"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.6"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "IRTools", "InteractiveUtils", "LinearAlgebra", "MacroTools", "NaNMath", "Random", "Requires", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "4f9a5ba559da1fc7474f2ece6c6c1e21c4ab989c"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.16"

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "9e7a1e8ca60b742e508a315c17eef5211e7fbfd7"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─664f3378-77e5-43f2-adcf-74d567da2725
# ╟─2cb10bd2-9d8b-47f1-a442-2fed03be63e3
# ╠═f0149a28-4cd8-4d85-a60f-6a6821d02563
# ╟─d11a6c5b-fabd-4863-80a3-22566dc590f1
# ╠═cd8c69bf-cb8d-4a65-b273-f2e0e2daec37
# ╟─d4b7a354-9fac-4fa7-b7d8-0d5adc230123
# ╠═56ff2c52-9965-4f76-8605-8d3895873ebb
# ╟─fdbb17b2-5127-4893-8064-b76eac713c5d
# ╠═0dfd2d12-8259-4a01-b500-0d6aaa75c708
# ╟─b88947e5-c28f-481d-8e25-807516a02a49
# ╠═d4519448-75c4-4dc6-a153-133a99d6729a
# ╟─4df3388a-d58f-47f5-b795-02cf150ac7a4
# ╠═4eb0419d-87fa-4205-8eef-ae6f462bd9eb
# ╟─ee75ca1a-12bc-4f14-8601-d4aa7de3fc5e
# ╠═dcf46f04-96e6-4524-ba49-dba2f353c1ba
# ╠═dfac7b20-3ea3-4f8c-833d-4958c464ceec
# ╠═5d2874b0-4826-4dfe-8db5-384ec291001f
# ╠═494319c8-0670-4f7f-a5bf-4306f48cb373
# ╠═e5ce855e-8768-4b50-b526-d9db9dd04ed5
# ╠═b5ce02d6-bffd-411e-a42d-a364cf47197f
# ╠═f27e4e55-dabe-48c1-b4e1-55d44c636fcd
# ╠═ab369017-eade-476d-867d-6aac818f6d45
# ╠═bbc37085-470d-4234-89d4-a0635fe47192
# ╠═15efa167-17ee-4f13-8584-f5a68d01fc67
# ╟─801bec8f-108b-411b-92e5-5c13f2a52f6c
# ╟─46b2ff4e-5055-48bf-a425-84768ba6d646
# ╠═a6f4ba5b-465c-4a79-b421-15b85744ebdd
# ╠═eed7e56c-8e14-4f99-b692-f23bb48eb0c8
# ╟─b18786b4-38ba-47ad-83c1-4952d4fa085c
# ╠═f69d1742-24b2-489c-9bbf-068c30cf6fd3
# ╠═86e8bc44-c3ca-4d59-be1f-d5d6e3891bca
# ╟─a9cf3d23-36d5-4d07-a3d2-462423dbc953
# ╠═25bc1007-cb4d-4cbe-972c-06ebb962c81c
# ╠═25f790c3-a12b-43ab-8cb8-14057504f55a
# ╟─b59a4849-dd1d-4ecc-bfc9-9ff482b3f175
# ╠═0045d2f1-7b0e-43c5-84d2-d71cbefa04f2
# ╟─cef01ad3-667d-4c2e-a6d5-3003d36cf0e3
# ╠═b89653bf-6dfc-4886-afe9-9ac4a67387ea
# ╟─e420f761-5f39-4e67-a3a1-8706631a0aa1
# ╠═7182a84a-e86e-44dc-9bf0-55a044e20346
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002