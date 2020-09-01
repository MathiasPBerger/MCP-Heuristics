using DelimitedFiles
using PyCall
#using Plots
using StatsBase

#################### Useful Functions #######################

pickle = pyimport("pickle")

function myunpickle(filename)

  r = nothing
  @pywith pybuiltin("open")(filename,"rb") as f begin
    r = pickle.load(f)
  end
  return r

end

function submodularity_test(D::Array{Float64, 2}, beta::Float64, locset1::Array{Int64}, locset2::Array{Int64})

  c1, c2 = floor((1-beta)*length(locset1))+1, floor((1-beta)*length(locset2))+1
  score_locset1, score_locset2 = sum(sum(view(D, :, locset1), dims = 2) .>= c1), sum(sum(view(D, :, locset2), dims = 2) .>= c2)

  u_locsets, i_locsets = union(locset1, locset2), intersect(locset1, locset2)
  c_u, c_i = floor((1-beta)*length(u_locsets))+1, floor((1-beta)*length(i_locsets))+1

  score_u_locsets = sum(sum(view(D, :, u_locsets), dims = 2) .>= c_u)

  if length(i_locsets) == 0.0
    score_i_locsets = 0.
  else
    score_i_locsets = sum(sum(view(D, :, i_locsets), dims = 2) .>= c_i)
  end

  return (score_u_locsets+score_i_locsets)<=(score_locset1+score_locset2)

end

function supermodularity_test(D::Array{Float64, 2}, beta::Float64, locset1::Array{Int64}, locset2::Array{Int64})

  c1, c2 = ceil(beta*length(locset1)), ceil(beta*length(locset2))
  score_locset1, score_locset2 = sum(sum(view(D, :, locset1), dims = 2) .>= c1), sum(sum(view(D, :, locset2), dims = 2) .>= c2)

  u_locsets, i_locsets = union(locset1, locset2), intersect(locset1, locset2)
  c_u, c_i = ceil(beta*length(u_locsets)), ceil(beta*length(i_locsets))

  score_u_locsets = sum(sum(view(D, :, u_locsets), dims = 2) .>= c_u)

  if length(i_locsets) == 0.0
    score_i_locsets = 0.
  else
    score_i_locsets = sum(sum(view(D, :, i_locsets), dims = 2) .>= c_i)
  end

  return (score_u_locsets+score_i_locsets)>=(score_locset1+score_locset2)

end

function locations_selector(locations_vector::Array{Int64})

  L1, L2 = sample(locations_vector, 2)
  locset1, locset2 = sample(locations_vector, L1, replace=false), sample(locations_vector, L2, replace=false)

  return locset1, locset2

end

function tester(D::Array{Float64, 2}, beta::Float64, T::Int64, test_type::String)
  L = size(D)[2]
  locations_vector = [i for i in 1:L]
  for t in 1:T
    locset1, locset2 = locations_selector(locations_vector)
    if test_type == "submodularity"
      if(submodularity_test(D, beta, locset1, locset2) == true)
        return locset1, locset2
      end
    else
      if(supermodularity_test(D, beta, locset1, locset2) == false)
        return locset1, locset2
      end
    end
  end
end


########### Testing ######

unpickled = myunpickle("../data/offshore_full_country_10y_min.p")
D  = convert.(Float64, unpickled["criticality_matrix"])
W, L = size(D)

D_c = ones(W, L) - D

beta = 1.0
T = 10
