(* ::Package:: *)

(* :Title: Differential Forms, Version 3.2, February 2014*)

(* :Author: Frank Zizza
	    Colorado State University - Pueblo
	    frank.zizza@colostate-pueblo.edu

   :Additions by: Ulrich Jentschura, 
                  Ludwig-Maximilians-Universitaet,
                  Muenchen,
                  100115.2250@compuserve.com

*)

(* :Summary:
   A Mathematica package that impliments the exterior algebra of differential 
   forms in n-dimensional Cartesian space. 
*)

(* :Context: DifferentialForms` *)

(* :Package Version: 3.2 Beta*)

(* :Copyright: Copyright 2014 *)

(* :History:
  Created by Frank Zizza at Willamette University, Summer 1991
  Revised Spring 1994, Summer 1996, Winter 2007, Spring 2014
*)

(* :Keywords: 

  Differential Form, Exterior algebra, Exterior derivative 
*)

(* :Sources:
  Sternberg, "Lectures in Differential Geometry"
  Spivak, "Calculus on Manifolds"
  Flanders, "Differential Forms" 

*)


(* :Mathematica Version: 9.0.1.0 *)

(* :Limitations: 

For convenience, and to make the input as close as possible to 
conventional mathematical notation, d is overloaded with too 
many transformation rules.  The price paid for this convenience
is greater difficulty manipulating differential forms.  

*)


Unprotect[TensorProduct]
(*********************************************************)

BeginPackage["DifferentialForms`"];

(*********************************************************) 

(*Usage messages*)  


DifferentialForms::usage="This package provides functions for calculations \
in the exterior algebra of differential forms on R^n. The functions \
defined in this package are:\n\n

Function name            Alternative form\n
------------------       -----------------\n
Basis\n
Boundary\n
Chain\n
Coefficients\n
cod\n
Component\n
ComponentList\n
ExteriorDerivative       d\n
ExteriorProduct          Wedge or :^:\n
FormQ\n
HodgeStar\n
HomotopyOperator\n
InnerProduct\n
Integral\n
InvertMetric\n
Laplace\n
LieDerivative\n
Orientation\n
Pair\n
Pullback\n
Push\n
Restrict\n
Riemannian\n
Standard\n
TensorProduct           t\n
UnitFrame \n
$CoordinateFunctions\n\n
For further information about a specific function, type ?<function name>."


Basis::usage=  "Basis[ n, {x, y,...}] creates a list of the n dimensional forms assuming {x, y, ...} is a complete list of the coordinate functions.";


Boundary::usage= "Boundary[C] computes the boundary of the chain C (See Chain).  Boundary is a linear map and automatically reduces overlapping and degenerate edges as much as possible.";



Chain::usage= "Chain[transformation:{__Rule}, limits:{_Symbol,_,_}..]  represents a parameterized surface whose domain is a product of intervals.  The first arguement is the parameterization of the surface expressed as a set of rules."


Coefficients::usage= "Coefficients[Y_, basis:{__}, BASIS:{__}] is used for curvature calculations.  Y is a vector valued alternating one form, basis is a basis for the alternating one forms, and BASIS is an orthonormal frame.   Coefficients returns a matrix A of functions with the property that (basis . A) . BASIS is the expansion of the vector valued form Y in terms of the orthonormal vectors in BASIS.  That is, (basis . A) are the alternating one form coefficients of Y relative to BASIS. BASIS must be an orthonormal frame.";


cod::usage =  "cod[w, M] calculates the co-exterior derivative of the differential form w relative to the metric M.  cod[ w, M ] is equivalent to HodgeStar[ d[ HodgeStar[ w, M ] ], M] where HodgeStar represents the star operation relative to the metric M. (See HodgeStar).  The metric M is a metric of R^n expressed as a symmetric two form (See Metric).";


Component::usage =  "Component[ w, basisform] extracts the coefficient of basisform that appears  in the form w.";


ComponentList::usage = "Component[ w, Basis -> {coordinates}] extracts the coefficients of w relative to the basis of dim[w] forms in the given coordinates.";


Coordinates::usage =  "HomotopyOperator[ d[x, y] ] computes using {x, y, z} as the assumed coordinates.  To change the coordinates enter HomotopyOperator[ d[x,y], Coordinates -> {x, y, z}]."


d::usage=
	"d[x_Symbol,y_Symbol,..] is a compact method to enter the exterior differential form dx^dy^... .  For functions and forms, d computes the exterior derivative and is the shorthand quivalent to ExteriorDerivative[ expression ]."


ExteriorDerivative::usage=
	"ExteriorDerivative[expression] computes the exterior derivative of expression.  This function can be called with the conventional symbol d."  


ExteriorProduct::usage= "ExteriorProduct[obj__] is the natural bilinear operation in the exterior  lgebra.  ExteriorProduct[d[s], d[t]] can be more easily entered as d[s,t].  ExteriorProduct is also know as the wedge product.  An alternative method is to use the Mathematica wedge symbol which can be obtained as [Esc]^[Esc]."


FormQ::usage= "FormQ[expr_] returns True if expr contains expressions involving differential forms."
	


HodgeStar::usage= "HodgeStar[ w, metric ] computes the Hodge star form dual to the differential form w under the metric.";




HomotopyOperator::usage= "HomotopyOperator[n-form] is a function that computes an (n-1)-dimensional alternating form from an n-dimensional form w expressed in the coordinate system {x, y, z} that satisfies the identity HomotopyOperator[ d[ w ] ] + d[ HomotopyOperator[ w ] ] == w."


InnerProduct::usage= "InnerProduct[u, v, M] calculates the inner product of u and v relative to the metric M.  (See Metric.) InnerProduct calculates the inner products for vectors and for differential forms.  For vectors and 1-dimensional forms, it simply evaluates the vector or form with the metric tensor using Pair.  For higher dimensional differential forms, it evaluates the determinant of the inner product of all 1-dimensional differential form factors of a factorization of u and v.";

InteriorProduct::usage=  "InteriorProduct[vectorfield, differentialform] computes the interior product of vector fields and exterior differential forms."; 


InvertMetric::usage= "InvertMetric[m] generates the object in the tensor product of V and V  that is dual to the metric m as an element of the tensor product of V* and V*.  This tensor can be used to perform the classical operation of raising the indices of a tensor."  


Integral::usage= "Integral[differential form, chain] integrates differential forms over the chain.  The chain is represented abstractly as a linear combination of chains created with the function Chain. (See Chain.)
	\n\nExamples:\n\nThe area of the unit square is calculated by:\
	\nIntegral[ d[x,y] , Chain[ {x -> s, y -> t}, {s, 0, 1}, {t, 0, 1}]].\
	\n\nThe area of the circle of radius R is calculated by:\n\
	SetAttributes[R, Constant];\nIntegral[ d[x,y] , \
	Chain[ {x -> r Cos[theta], y -> r Sin[theta]}, {r, 0, R}, {theta, 0, 2Pi}]].\
	\n\nThe surface area of a unit sphere is calculated by:\n\
	Integral[(x) d[y,z] + (-y) d[x,z] + (z) d[x,y],\
	\n\tChain[{x -> Cos[theta] Sin[phi], y -> Sin[theta] Sin[phi], z -> Cos[phi]},\
	\n\t{theta, 0, 2Pi}, {phi, 0, Pi}]]\n\nThe volume of the sphere of radius R \
	is calculated by:\nIntegral[ d[x,y,z], \
	Chain[-1, {x -> r Cos[theta] Sin[phi], y -> r Sin[theta] Sin[phi], z -> r Cos[phi]},\
	{r, 0, R}, {theta, 0, 2Pi}, {phi, 0, Pi}]]  (-1 in chain reverses the orientation \
	of the chain.  The assumed orientation on the region corresponds to the \
	ordering obtained on {r, theta, phi} from the Sort function.)\
	\n\nStokes Theorem:\n\nIntegral[ d @ ((x/2) d[y] - (y/2) d[y]) , \
	Chain[ {x -> s, y -> t}, {s, 0, 1}, {t, 0, 1}]] ==\
	\nIntegral[ ((x/2) d[y] - (y/2) d[y]) , \
	Boundary @ Chain[ {x -> s, y -> t}, {s, 0, 1}, {t, 0, 1}]]\
	\n\nIntegral[ d @ (x d[y,z]) , \
	Chain[-1, {x -> r Cos[theta] Sin[phi], y -> r Sin[theta] Sin[phi], z -> r Cos[phi]},\
	{r, 0, R}, {theta, 0, 2Pi}, {phi, 0, Pi}]] ==\
	\nIntegral[ x d[y,z] , Boundary @ Chain[-1, \
	{x -> r Cos[theta] Sin[phi], y -> r Sin[theta] Sin[phi], z -> r Cos[phi]}, \
	{r, 0, R}, {theta, 0, 2Pi}, {phi, 0, Pi}]].  (See Boundary.)"  


Laplace::usage= "Laplace[altform, metric], the Laplace-Beltrami operator. (See Metric)";



LieDerivative::usage=
	"LieDerivative[V, obj] computes the Lie Derivative of the object obj with respect \
	to the vector field V.  Obj can be a function, a differential form, or another \
	vector field.\
	\n\nExamples:\n\nLieDerivative[ a[x,y] X[x] + b[x,y] X[y], f[x, y] ] == \
	b[x, y]*Derivative[0, 1][f][x, y] + a[x, y]*Derivative[1, 0][f][x, y]\
	\n\nLieDerivative[ a[x,y] X[x] + b[x,y] X[y], f[x,y] d[x] + g[x,y] d[y] ] \
	computes the Lie derivative of the 1-dimensional differential form \
	f[x,y] d[x] + g[x,y] d[y] with respect to the vector field \
	a[x,y] X[x] + b[x,y] X[y].\
	\n\nLieDerivative[ a[x,y] X[x] + b[x,y] X[y], f[x,y] d[x,y] ] computes the \
	Lie derivative of f[x,y] d[x,y] with respect to a[x,y] X[x] + b[x,y] X[y].\
	\n\nLieDerivative[ a[x,y] X[x] + b[x,y] X[y], f[x,y] X[x] + g[x,y] X[y] ] \
	computes the Lie derivative of the two vector fields.  This corresponds to \
	the Lie bracket of two vector fields.  Thus, it is possible to define \
	LieBracket[V_, W_] := LieDerivative[V, W] and symbolically verify properties \
	of LieBracket in a given dimension."  

Metric::usage=

	"Metrics are entered as sums of tensor products of linear functions on R^n.  \
	They evaluate to real numbers when supplied with two vectors via the \
	operation of pairing. (See Pair).  A metric must be supplied as an option \
	to the HodgeStar operator, the Laplace operator and to the co-exterior derivative \
	operator cod.\n\nExamples:\n\nIn Cartesian coordinates x and y, the standard \
	metric in R^2 is TensorProduct[t[x], t[x]] + TensorProduct[t[y], t[y]].  \
	(t[x] and t[y] are the standard basis of linear functionals on R^2.)  \
	This can be more easily entered as t[x,x] + t[y,y].\n\nIn Cartesian \
	coordinates x, y and z, the standard metric in R^3 is t[x,x] + t[y,y] + t[z,z].\
	\n\nIn polar coordinates, the standard metric in R^2 in terms of the \
	coordinates r and theta is t[r,r] + r^2 t[theta, theta].  Alternatively, \
	this metric can be computed by pulling back the metric t[x,x] + t[y,y] \
	under the transformation that gives polar coordinates, \
	{x -> r Cos[theta], y -> r Sin[theta]} -- Pullback[t[x,x] + t[y,y], \
	{x -> r Cos[theta], y -> r Sin[theta}].  \n\nSimilarly, the standard \
	metrics in cylindrical and spherical coordinates in R^3 can be obtained \
	by pulling back t[x,x] + t[y,y] + t[z,z] by the transformations \
	{x -> r Cos[theta], y -> r Sin[theta], z -> z} and \
	{x -> r Cos[theta] Sin[phi], y -> r Sin[theta] Sin[phi] , z -> r Cos[phi]} \
	respectively.  The procedure works for any change of coordinates."

Orientation::usage=

	"Orientation[metric] calculates a unit length generator of the top \
	dimensional exterior algebra on the variables contained in metric.  \
	It assumes that the orientation is consistent with the orientation \
	on the variable produced by the Sort function.\
	\n\nExamples:\n\nOrientation[t[x,x] + t[y,y]]\
	\n\nOrientation[t[r,r] + r^2 t[theta, theta] + t[z,z]].";


Pair::usage=

	"Pair[v, f] is the fundamental bilinear operation of evaluating a form \
	f on a vector v.  It is the function that makes objects created with t[x__] \
	linear functionals on the vector space of objects created with \
	X[x__].\n\nExamples:\n\nPair[a X[x] + b X[y], c t[x] + d t[y]] produces \
	the output a*c + b*d.\n\nPair[a X[x, y], b t[x, y]] produces a*b.\n\n\
	Pair[a X[x, y], b t[x, z]] produces 0.\n\nPair can also be used to \
	partially evaluate the metric with a vector field. This corresponds to the \
	classical operation of lowering indices.\n\nExample:\n\n\
	If g[x,x] t[x,x] + g[x,y] t[x,y] + g[x,y] t[y,x] + g[y,y] t[y,y] is the \
	general metric on R^2 and if (a X[x] + b X[y]) is any vector, the one form \
	that corresponds to lowering the indices of (a X[x] + b X[y]) is obtained from \
	Pair[a X[x] + b X[y], g[x,x] t[x,x] + g[x,y] t[y,x] + g[x,y] t[x,y] + g[y,y] t[y,y]] \
	\n\nPair can also be used to partially evaluate the dual of the metric with a \
	linear functional.  That corresponds to raising the indices of the linear \
	functional.  The dual of the metric can be obtained using InvertMetric.\
	\n\nExample:\n\nLet t[x,x] + t[y,y] be the usual metric in R^3 in Cartesian \
	coordinates and let f[x,y,z] be a scalar field on R^3, then the gradient \
	of f[x,y,z] is the vector field defined by \
	Pair[ InvertMetric[ t[x,x] + t[y,y] ], ExteriorDerivative[ f[x,y,z] ] ].  \
	This method of constructing the gradient of a function is very general; it \
	works in any coordinates system and with any metric."  


Pullback::usage=

	"Pullback[ tensor, transformation] pulls the tensor back \
	from one coordinate system back to another coordinate system.  This operation and \
	the properties differential forms exhibit under this operation are two of the \
	primary reasons differential forms are such a convenient formalism.  Transformations \
	are represented as rules sets.  For example, the transformation from polar \
	coordinates to rectangular coordinates is represented by the rule set \
	{x -> r Cos[theta], y -> r Sin[theta]}.  If a function from say R^2 to R^2 is expressed \
	in the usual form F[{u_, v_}] = { x[u, v], y[u, v] }, then the rule set for this \
	transformation can be easily obtained with Thread[{x, y} -> F[{u, v}]]\
	\n\nExamples:\n\nThe pullback of the standard area form in cartesian \
	coordinates x and y, d[x] ^ d[y], to polar coordinates r and theta is \
	calculated with Pullback[ d[x,y], {x -> r Cos[theta], y -> r Sin[theta]}].\
	\n\nThe pullback of the standard volume form in cartesian coordinates x, y \
	and z, d[x] ^ d[y] ^ d[z], to cylindrical coordinates r, theta and z is \
	calculated with Pullback[ d[x,y,z], {x -> r Cos[theta], y -> r Sin[theta], z -> z}].\
	\n\nThe pullback of the standard volume form in cartesian coordinates x, y and z, \
	d[x] ^ d[y] ^ d[z], to spherical coordinates r, theta and phi is calculated \
	with Pullback[ d[x,y,z], {x -> r Cos[theta] Sin[phi], y -> r Sin[theta] Sin[phi], \
	z -> r Cos[phi]}].\n\nThe pullback of the standard volume form in cartesian coordinates \
	x, y and z, d[x] ^ d[y] ^ d[z], to spherical coordinates r, theta and phi is \
	calculated with Pullback[ d[x,y,z], {x -> r Cos[theta] Sin[phi], y -> r Sin[theta] \
	Sin[phi], z -> r Cos[phi]}].\n\nThe pullback of the general two form in cartesian \
	coordinates x and y, f[x,y] d[x] ^ d[y], to any coordinates u and v is calculated \
	with Pullback[f[x,y] d[x] ^ d[y], {x -> x[u, v], y -> y[u, v]}].\n\nThe pullback \
	of the metric two tensor in cartesian \
	coordinates x and y, t[x,x] + t[y,y], to polar coordinates is calculated \
	with Pullback[t[x,x] + t[y,y], {x -> r Cos[theta], y -> r Sin[theta]}].\n\nPullback is \
	used in many of the other functions in this package, in particular, Integral which \
	integrates a differential form over chains (see Integral and Chain) uses Pullback \
	to pull the differential form which is the integrand back to the domain of each of \
	the chains (parameterized surfaces).."  


Push::usage=
	"Push[vectorfield, transformation] pushes forward a vector field under a \
	transformation.  This operation is the adjoint of Pullback under the \
	bilinear operation of Pair."  

 
Restrict::usage=

	"Restrict[form, trans] restricts the differential form to a point. \
	The point is represented as a set of transformation rules.  \
	For example, Restrict[(x^2)d[x,y], {x -> a, y -> b}] produces (a^2)dx^dy."  


Riemannian::usage=

	"Riemannian is an option for Orientation.  The default setting is \
	True, which means that all calculations which involve a metric assume \
	the metric is positive definite.  If the metric is not positive definite, \
	some calculations will contain sign errors.  For non riemannian metrics, \
	set this option to False.  Mathematically the results obtained by setting \
	this option to False will always be valid, the only point is to avoid \
	un-necessary Abs and Sign calls in the riemannian cases.\
	\n\nOrientation is used in all calculations which use the \
	HodgeStar operation, in particular cod and Laplace.";




Standard::usage=

	"Standard[d[x,y]] converts d[x,y] into e[x,y] which can be used for \
	rule manipulations.  (a_ d[x_] -> a fails because d also computes \
	exterior derivatives.)"
	      

Simple::usage=

	"Simple[expr] is defined as expanding and then simplifying expr. \
	This procedure ensures successful simplification."


Tensor::usage=
	
	"Is an alternative form of TensorProduct, see TensorProduct";


TensorProduct::usage=

	"TensorProduct[obj__] is the natural bilinear operation in the tensor \
	algebra.   TensorProduct[X[s], X[t]] can be more easily entered as X[s,t], \
	TensorProduct[X[s], X[t], X[u]] can be  entered as X[s,t,u], etc.  \
	TensorProduct[d[s], d[t], d[u]] can be entered as t[s,t,u] (d[s,t,u] \
	is the exterior product, ExteriorProduct[ d[s], d[t], d[u] ])."  


t::usage=

	"t[x_Symbol] is the linear functional dual to the vector field X[x].  \
	In the formatted output t[x] is rendered as d[x], the alternating one \
	form; both objects are equal.\
	\n\nExample:\n\nThe most general linear functional in R^3 using the \
	coordinate system {x, y, z} can be represented by \
	f[x,y,z] t[x] + g[x,y,z] t[y] + h[x,y,z] t[z].\n\nt[x_Symbol,y_Symbol,..] \
	is the tensor product of the functionals d[x] and d[y],... and is equivalent \
	to TensorProduct[t[x], t[y], ...].  t[x,y,...] is dual to the object \
	X[x,y,...].  In the formatted output, TensorProduct[t[x], t[y], ...] \
	is rendered as d[x] o d[y] o ... .\n\nExample:\n\nMetrics are represented \
	as symmetric 2-tensors, the most general one in R^2 equal to \
	g11[x,y] t[x,x] + g12[x,y] t[x,y] + g12[x,y] t[y,x] + g22[y,y] t[y,y].\
	\n\nt is the top level user interface to create tensors that are internally \
	represented as DifferentialForms`Private`form[coefficient, listofvariables]."  


Wedge::usage=

	"Wedge is an alternative name for ExteriorProduct. (See ExteriorProduct)"

X::usage= 

	"X[x_Symbol] is the vector dual to the linear functional t[x].\
	\n\nExample:\n\nThe most general vector field in R^3 using the \
	coordinate system {x, y, z} can be represented by \
	f[x,y,z] X[x] + g[x,y,z] X[y] + h[x,y,z] X[z].\
	\n\nX[x_Symbol,y_Symbol,..] is the tensor product of the vector \
	fields X[s] and X[t],... and is equivalent to \
	TensorProduct[X[x], X[y], ...].  X[x,y,...] is dual to the object \
	t[x,y,...].  In the formatted output, TensorProduct[X[x], X[y], ...] \
	is rendered as X[x] o X[y] o ... .\n\nX is the top level user interface \
	to create tensors that are internally represented as \
	DifferentialForms`Private`vec[coefficient, listofvariables]."

UnitFrame::usage=

	"UnitFrame[{x,y,___}, metric] constructs a list of unit vectors \
	from the list {d[x], d[y], ....}.\
	\n\nExamples:\n\n\
	UnitFrame[{r, theta, z}, t[r,r] + r^2 t[theta, theta] + t[z,z]].";
	
$CoordinateFunctions::usage = "";


(*End of usage messages*)  

(************************************************************)
(************************************************************)

Begin["`Private`"];

(*These are the functions called to make algebraic objects*)

MakeLinearObject[obj_] := 

	(obj /: obj[a_, x___] + obj[b_, x___] := obj[a + b, x];
	 obj /: a_ obj[c_, x___] := obj[a c, x] /; FreeQ[a, obj];
	 obj /: obj[0, x___] := 0)

MakeLinearMap[fcn_] :=
	(fcn[S_Plus, C___] := fcn[#, C]& /@ S;
	 fcn[P_Times, C___] := fcn[Expand[P], C];
	 fcn[0, C___] := 0)


MakeMultilinearMap[fcn_] :=
	(fcn[a___, S_Plus, b___] := fcn[a, #, b]& /@ S;
	 fcn[a___, P_Times, b___]:= fcn[a, Expand[P], b] /; (Expand[P] =!= P);
	 fcn[a___,0,b___] := 0)


(************************************************************)
(************************************************************)
(*vector space objects*)

MakeLinearObject[vec]


Format[vec[a_, x:{__}]] := 

SequenceForm @@ Drop[Flatten[
{"(",a,") ",Table[{" o ", "X[", x[[i]], "]"},{i,1,Length[x]}]}],{4}]


X[x__Symbol] := vec[1, {x}] (*user interface*)

(************************************************************)
(************************************************************)
(*linear functionals*)

MakeLinearObject[form]


Format[form[a_, x:{__}]] := 
SequenceForm @@ Drop[Flatten[
 {"(",a,") ",Table[{" o ", "d[", x[[i]], "]"}, {i,1,Length[x]}]}], {4}]


(*One forms will be treated as alternating one forms*)
t[x_Symbol] := altform[1,{x}]  


t[x__Symbol] := form[1, {x}] (*User interface*)



(************************************************************)
(************************************************************)
(*alternating linear functionals*)

MakeLinearObject[altform]


altform[c_, x:{__Symbol}] := 0 /; Signature[x] == 0

altform[c_, x:{__Symbol}] := 
	altform[Signature[x]*c, Sort[x]] /; !OrderedQ[x]

altform[a_, {}] := a;  (*this is used in InteriorProduct*)

altform /: altform[a_, {y_Symbol}]/altform[b_, {y_Symbol}] := (a/b)

altform /: altform[a_, {y_Symbol}]/altform[b_, {x_Symbol}] := (a/b) y'[x]

ExpressionQ[x_] := TrueQ[Head[x] =!= Symbol && Head[x] =!= Pattern]

ExpressionQ[x_List] := Or @@ (ExpressionQ /@ x)

altform[a_, {x__}] := (a * (ExteriorProduct @@ (ExteriorDerivative /@ {x}))) /; ExpressionQ[{x}]

altform /: Integrate[ altform[ f_, x_ ], {t_, a_, b_} ] := altform[ Integrate[ f, {t, a, b} ], x ] /; FreeQ[{x}, t]

	
Format[altform[a_, x:{__}]] := 
  SequenceForm @@ Drop[Flatten[
    {"(",a,") ",Table[{" ^ ", "d", x[[i]],""}, {i,1,Length[x]}]}], {4}] 


Format[altform[a_, x:{__}], TeXForm] := 
 SequenceForm @@ Drop[Flatten[
 {"(", a ,") ",Table[{"{\\wedge }", "d", x[[i]]}, {i,1,Length[x]}]}], {4}]

Format[altform[a_, {x__}], InputForm] := HoldForm[a d[x]]

(*User interface*)

SetAttributes[d, {Listable}];     (*for matrix valued forms*)

d[x_] := ExteriorDerivative[x]

d[x__Symbol] := altform[1, {x}] /; FreeQ[Attributes[{x}], Constant]

d[c__Symbol] := Message[d::const, {c}] /; Length[{c}] > 1

d::const = "The list of variables `` contains a constant."

(************************************************************)
(************************************************************)
(*Utilities*)

Dim[altform[a_, x:{__}]] := Length[x]

Dim[S_] :=  Module[{s}, If[ SameQ @@ ( s = Map[Dim, Apply[List, Expand[S]]] ), s[[1]], s ]] /; FormQ[S]


FormQ[f_] := Not[FreeQ[f,altform] && FreeQ[f,form]] 

tensorQ[f_] := Not[FreeQ[f,altform] && FreeQ[f,form] && FreeQ[f, vec]]

Simple[x__] := Simplify[Expand[x]] //. absrules

absrules = {	Abs[a_*b_] :> Abs[a]*Abs[b],
		Abs[-1*a_] :> Abs[a],
		Abs[a_^n_] :> Abs[a]^n /; EvenQ[n],
		Abs[a_/b_] :> Abs[a]/Abs[b] }


UnitFrame[vars_List, metric_] := 
	(X[#]/PowerExpand[Sqrt[InnerProduct[X[#], X[#], Simple[metric]]]])& /@ vars




(************************************************************)
GetVariables[expr_]:=
	Select[Union[Cases[N[expr], _Symbol, {-1}]], (!MemberQ[Attributes[#], Constant])&]

Component[altform[a_, {x__}], altform[1, {y__}]] := If[{x} === {y}, a, 0]

MakeLinearMap[Component]

ComponentList[expr_, opt___Rule] := 
	Module[{givenvars, exprvars = GetVariables[expr], allvars},
		givenvars = Basis /. {opt} /. Options[ComponentList];
		If[Complement[exprvars, givenvars] =!= {},
				Message[ComponentList::vars, allvars = Union[exprvars, givenvars]];,
				allvars = Sort[givenvars]];
		Component[expr, #]& /@ Basis[allvars, Dim[expr]] ]/; FormQ[expr]

Options[ComponentList] = {Basis -> {}};

ComponentList::vars = 
	"Given differential forms contains variables \
	not found in given list of basis variables, or \
	an explicit basis was not given.  Using basis `1`."

(************************************************************)

(************************************************************)
(*The bilinear operation of pairing.  Used to make forms linear *)
(*functionals on vecs                                           *)

(*Usual case*)
Pair[vec[a_, x:{__}], form[b_, y:{__}]] := 
	If[x === y, a b, 0] /; (Length[x] == Length[y])

(*This handles the complication created by one forms represented *)
(*as alternating one forms                                       *)
Pair[vec[a_, x:{_}], altform[b_, y:{_}]] := 
	If[x === y, a b, 0]

(*Contractions*)
Pair[vec[a_, {x_}], form[b_, {y_, z_}]] := 
	If[x === y, altform[a b, {z}], 0]

Pair[vec[a_, {x_}], form[b_, {y_, z__}]] :=
        If[x === y, form[a b, {z}], 0]

Pair[vec[a_, {x_, y_}], head_[b_, {z_}]] := 
	If[y === z, vec[a b, {x}], 0] /;
		(head == form || head == altform)

MakeMultilinearMap[Pair]


(************************************************************)
(************************************************************)
(*Restriction to a point*)

Restrict[L_List,trans:{__Rule}] := Restrict[#,trans]& /@ L

Restrict[altform[a_,x:{__}], trans:{__Rule}] := 
	altform[a /. trans, x]

Restrict[form[a_,x:{__}], trans:{__Rule}] := 
	form[a /. trans, x]

Restrict[vec[a_,x:{__}], trans:{__Rule}] := 
	vec[a /. trans, x]

MakeLinearMap[Restrict]

(************************************************************)
(************************************************************)
(*Bilinear operation of tensor product*)

TensorProduct[single_] := single

TensorProduct[vec[a_, x:{__}], vec[b_, y:{__}], C___] := 
		TensorProduct[vec[a b, Join[x,y]], C]

TensorProduct[head1_[a_,x:{__}], head2_[b_, y:{__}], C___] :=
	TensorProduct[form[a b, Join[x,y]], C] /; 
		(head1 == form || (head1 == altform && Length[x] == 1)) &&
		(head2 == form || (head2 == altform && Length[y] == 1))

TensorProduct[A___, f_, B___] :=   f TensorProduct[A, B] /; !FormQ[f]

MakeMultilinearMap[TensorProduct]


(************************************************************)
(************************************************************)
(*Exterior products of alternating forms*)


ExteriorProduct[single_altform] := single

ExteriorProduct[altform[a_, x:{__}], altform[b_, y:{__}],C___] :=  
	ExteriorProduct[altform[a b, Join[x,y]], C]

ExteriorProduct[A___, f_, B___] :=   f ExteriorProduct[A, B] /; !FormQ[f]

MakeMultilinearMap[ExteriorProduct]


(************************************************************)
(************************************************************)
(* Wedge is an extension of ExteriorProduct *)

Wedge[x_List,y_List] := Inner[ExteriorProduct,x,y,Plus]

Wedge[x__] := ExteriorProduct[x]

(* Tensor is an extension of TensorProduct *)

Tensor[x_List,y_List] := Inner[TensorProduct,x,y,Plus]

Tensor[x__] := TensorProduct[x]


(************************************************************)
(************************************************************)
(*Interior products*)

InteriorProduct[vec[a_, {x_}], altform[b_, y:{__}]] := 

   If[MemberQ[y,x],
	  (-1)^(Position[y,x][[1,1]] - 1)*altform[a b, Complement[y,{x}]], 

	  0]

MakeMultilinearMap[InteriorProduct]


(************************************************************)
(************************************************************)
(*Exterior derivatives*)

ExteriorDerivative[f_, opts___Rule] := 
	Module[{coords},
		coords = Coordinates /. {opts} /. Options[ExteriorDerivative];
		If[coords === Automatic, 
			(Dt[f] /. Literal[Dt[x_Symbol]] -> altform[1, {x}]),
			Apply[Plus, (altform[ D[f, #], {#}])& /@ coords]]] /;
					FreeQ[f, altform]&&FreeQ[f, form]&&FreeQ[f, vec]

ExteriorDerivative[altform[f_, x:{__Symbol}]] := 
	ExteriorProduct[ExteriorDerivative[f], altform[1, x]]
	
Options[ExteriorDerivative] = {Coordinates -> Automatic};

MakeLinearMap[ExteriorDerivative]

(************************************************************)
(************************************************************)
(*Pullbacks*)

Pullback[altform[c_, x:{__}], tranformation:{__Rule}] := 
	(c /. tranformation) * 
	ExteriorProduct@@ExteriorDerivative /@ (x /.tranformation)

Pullback[form[c_, x:{__}], tranformation:{__Rule}] := 
	(c /. tranformation) * 
	TensorProduct @@ ExteriorDerivative /@ (x /.tranformation)

Pullback[f_, transformation:{__Rule}] := (f /.transformation)/; 
	FreeQ[f,altform] && FreeQ[f,form]


Pullback[L_List,trans:{__Rule}] := Pullback[#,trans]& /@ L


MakeLinearMap[Pullback]

(************************************************************)
(************************************************************)
(*Push*)

Push[vec[a_, {x_}], transformation:{__Rule}] := 
	Block[{var, fcn},
		var = First /@ transformation;
		fcn = #[[2]]& /@ transformation;
		a Dot[D[#, x]& /@ fcn, X /@ var]]

Push[L_List, transformation:{__Rule}] := Push[#, transformation]& /@ L


MakeLinearMap[Push]


(************************************************************)
(************************************************************)
(*Lie Derivatives*)

LieDerivative[X_vec, f_] := 

	Pair[X, ExteriorDerivative[f]] /; 

		FreeQ[f, vec]&&FreeQ[f, altform] && FreeQ[f, form]

LieDerivative[vec[a_,{x_}], head_[1, {y_}]] :=
	If[x===y, ExteriorDerivative[a], 0] /; 

		(head == form || head == altform)

LieDerivative[vec[a_,{x_}], head_[c_, {y_}]] :=
	LieDerivative[vec[a,{x}], c] head[1,{y}] +
	c LieDerivative[vec[a,{x}], head[1, {y}]] /; 

		(head == form || head == altform)

LieDerivative[vec[a_,{x_}], altform_[b_, {y_, z__}]] :=
	ExteriorProduct[LieDerivative[vec[a,{x}], altform[1,{y}]], altform[b,{z}]] +
	ExteriorProduct[altform[1,{y}], LieDerivative[vec[a,{x}], altform[b,{z}]]]

LieDerivative[vec[a_,{x_}], form[b_, {y_, z__}]] :=
	TensorProduct[LieDerivative[vec[a,{x}], form[1,{y}]], form[b,{z}]] +
	TensorProduct[form[1,{y}], LieDerivative[vec[a,{x}], form[b,{z}]]]

LieDerivative[vec[a_,{x_}],vec[b_,{y_}]] := 

	LieDerivative[vec[a,{x}],b] vec[1, {y}] - b D[a,y] X[x]

MakeMultilinearMap[LieDerivative]

(************************************************************)
(************************************************************)
(*Integration of exterior differential forms*)

Integral[DF_, C_] := Int1[DF, C] (*User interface*)

Int1[DF_altform, C_Chain] := 

   Block[{integrand = Pullback[DF,Parameterization[C]]},
      If[integrand === 0, 
	 0,
	 Orientation[C]*Integrate[First[integrand],Sequence@@Limits[C]] 
	]] /; Dim[DF] == Dim[C]

Int1[f_, C_Chain] := 

	Orientation[C] * (f /. Parameterization[C]) /; 

		FreeQ[f, altform]

MakeMultilinearMap[Int1]

(************************************************************)
(************************************************************)
(*Singular chain objects*)

MakeLinearObject[Chain]

Chain[para:{__Rule}, limits:{_Symbol,_,_}..] := Chain[1, para, limits]
 

Chain[n_, para:{__Rule}, limits:{_Symbol,_,_}..] :=  0 /;
	And@@(NumberQ[#[[2]]]& /@ para)       (*reduces points to 0*)

Parameterization[C_Chain] := C[[2]]

Orientation[C_Chain] := First[C]

Limits[C_Chain] := Cases[C, {x_Symbol, _, _}]

Dim[C_Chain] := Length[Limits[C]]

boundary[var_Symbol,C_Chain]:=
	Block[{lims0, orient0, var0},
	var0 = (Select[Limits[C], MemberQ[#, var]&] // Flatten);
	orient0 = Orientation[C]*(-1)^(Position[Sort[Limits[C]], var][[1,1]] + 1);
	lims0 = Sequence @@ Complement[Limits[C], {var0}];
    Chain[ orient0, Parameterization[C] /. var -> var0[[3]], lims0]+
    Chain[-orient0, Parameterization[C] /. var -> var0[[2]], lims0] 

    ]

Boundary[C_Chain] := Block[{vars = First /@ Limits[C]}, 

	Plus @@ (boundary[#, C]& /@ vars)] 


MakeLinearMap[Boundary]

(************************************************************)
(************************************************************)
(*Invert the matrices in metrics represented as symmetric two forms*)

ReleasedSet[a_,b_] := (a = b);

InvertMetric[g_] := Block[{a,A,G,vars,vals, gg = Simple[g]},
	vars = Cases[gg, form[ _, {x__}] -> x] // Union;
	vals = Cases[gg, form[c_, {x__}] -> (a[x] -> c)];
	A = Outer[a, vars, vars] /. vals; a[__] = 0;
	ReleasedSet[Outer[G, vars, vars],Inverse[A]];
	Apply[Plus, Outer[vec[G[#1, #2], {#1, #2}]&, vars, vars], {0,1}]] 


(************************************************************)
(************************************************************)
(*Getting at coefficients in differential forms is hard because altform *)
(* is not externally visible and d computes exterior derivatives if the *)
(*head is not Symbol.  i.e.  the pattern   a_ d[x_] -> a  fails because *)
(*d computes the exterior derivative of x_.                             *)

SetAttributes[Standard, {Listable}] (*For matrix valued forms*)

Standard[altform[a_, {x__}]] := a e[x]

MakeLinearMap[Standard]

(************************************************************)
(************************************************************)
(*Used to get coefficients in curvature calculations with   *)
(*orthonormal  frames.                                      *)

Coefficients[Y_, basis:{__}] := 
	Block[{rules, dim},
    		dim = Length[basis];        
    		rules = Join[Thread[basis -> IdentityMatrix[dim]],{0 -> Table[0, {dim}]}]; 
		Transpose[Y /. rules]] /; FreeQ[Y, altform]&&FreeQ[basis, altform]
	
Coefficients[ Y_, basis:{__}, BASIS_?MatrixQ] := 
	Coefficients[ Y . Transpose[BASIS], basis] /;
		FreeQ[Y, altform]&&FreeQ[basis, altform]

Coefficients[ Y_, basis:{__}, BASIS_?MatrixQ] := 
	Coefficients[ Standard[Y] . Transpose[BASIS], Standard[basis]]

(************************************************************)
(************************************************************)
(*Homotopy operator contructions*)

Int2[ altform[f_, x:{__}]  ]:= 

	Module[{rule, t, int, coef},
		rule =  a_Symbol  :>  t * a  /;  And[
			!MemberQ[Attributes[a], Constant],
			MemberQ[Level[f, {-1}], a]];
		int = t^(Length[x] - 1) (f /. rule);
		coef = Integrate[int, {t, 0, 1}];
		altform[coef, x] ]

Int2[f_] := 

	Module[{rule, t, int},
		rule =  a_Symbol  :>  t * a  /;  And[
			!MemberQ[Attributes[a], Constant],
			MemberQ[Level[f, {-1}], a]];
		int = (1/t)*(f /. rule);
		Integrate[int, {t, 0, 1}]  ]  /; FreeQ[f, altform]

MakeLinearMap[Int2]

Options[HomotopyOperator] = {Coordinates -> {Global`x, Global`y, Global`z}};

MakeLinearMap[HomotopyOperator]

HomotopyOperator[form_, opts___] := 

	Module[{coord, radial},
		coord = Coordinates /. {opts} /. Options[HomotopyOperator];
		radial = Plus @@ ( coord *  X /@ coord );
		Int2[ InteriorProduct[ radial, form ] ] ]

(************************************************************)
(************************************************************)
(* coderivative *)

cod[f_,m_] := 0 /; FreeQ[f, altform] && FreeQ[f, form] && FreeQ[f, vec]

cod[w:altform[q_,x:{__Symbol}], metric_] :=
	Block[{n, p, g = Simple[metric]},
	n = Length[ Union[ Cases[g, form[_, {t__}] -> t] ] ];
	p = Length[x];
	(-1)^(n p + n + 1)*HodgeStar[ d[ HodgeStar[ w , g ] ] , g ]]


MakeLinearMap[cod] 

(************************************************************)
(************************************************************)
(* harmonic Laplace operator *)

Laplace[x_,metric_] := cod[d[x],metric] + d[cod[x,metric]]


(************************************************************)
(************************************************************)
(*InnerProducts*)

InnerProduct[ vec[a_, {x_}], vec[b_, {y_}], metric_] := 
	Pair[ vec[a b, {x, y} ], metric]

InnerProduct[ altform[a_, {x_}], altform[b_, {y_}], metric_] := 
	Pair[ InvertMetric[metric] , form[a b, {x, y} ] ]

InnerProduct[ altform[a_, {x__}], altform[b_, {y__}], metric_] := 
	0 /; Length[{x}] =!= Length[{y}]

InnerProduct[ altform[a_, {x__}], altform[b_, {y__}], metric_] := 
	a b Det[Outer[ InnerProduct[altform[1, {#1}], altform[1, {#2}], metric]&, {x}, {y}]]

InnerProduct[ a_, b_, metric_] := a b /; !tensorQ[a] && !tensorQ[b]
	
MakeMultilinearMap[InnerProduct]

(************************************************************)
(*HodgeStar*)

MetricToMatrix[g_] := 
	Block[{a,A,G,vars,vals, gg = Simple[g]},
		vars = Cases[gg, form[ _, {x__}] -> x] // Union;
		vals = Cases[gg, form[c_, {x__}] -> (a[x] -> c)];
		A = Outer[a, vars, vars] /. vals; a[__] = 0;
		{A, vars}];


Orientation[metric_, opt___] := 
	Block[{vars, omega, dot, g = Simple[metric]},
		vars = Union[ Cases[g, form[ _, {x__}] -> x] ];
		omega = ExteriorProduct@@(d[#]& /@ vars);
		dot = InnerProduct[omega, omega, g];
		riemannian = Riemannian /. {opt} /. Options[Orientation];
		If[riemannian, 
			omega/Sqrt[dot],
			(Sqrt[Abs[dot]]/dot)*omega]]

Options[Orientation] = {Riemannian -> True};

Indices[n_Integer?Positive, m_Integer?Positive] := 
	With[ {itterators = Table[Unique[z], {n}]},
		Flatten[
			Table @@
				Prepend[
					Transpose[{    
						itterators, 
						ReplacePart[1 + RotateRight[itterators], 1, {1}], 
						Table[m, {n}]}], 
					itterators],
			n-1]]

Basis[vars_, n_] := 
	Apply[altform[1, {##}]&, Part[Sort[vars], #]& /@ Indices[n, Length[vars]], {1} ] /; 
		0 < n <= Length[vars]

Basis[vars_, 0] := {1};

Basis[vars_, n_] := {} /; Length[vars] < n

MetricMatrix[metric_, p_] := MetricMatrix[metric, p] = 
	Block[{vars, g},
		g = Simple[metric];
		vars = Union[Cases[g, form[_, {var__}] -> var]];
		basis = Basis[vars, p];
		Outer[ InnerProduct[#1, #2, g]&, basis, basis]]

HodgeStar[ w:altform[a_, x:{___}] , metric_] := 
	Block[{ff, vars, v, basis, A, g = Simple[metric]},
		vars = Union[Cases[g, form[_, {var__}] -> var]];
		ff[u_] := If[FormQ[v = ExteriorProduct[ w, u ] ],
				First[ v ]/First[ Orientation[g] ], 
				0];
		basis = Basis[vars, Length[vars] - Length[x]];
		A = MetricMatrix[g, Length[vars] - Length[x]];
		basis . Inverse[A] . (ff /@ basis)]

HodgeStar[f_ , metric_] := f Orientation[metric] /; !FormQ[f]

MakeLinearMap[HodgeStar]

(************************************************************)
(************************************************************)

		
(*Protect Symbols defined in this package*)

Protect[Boundary, Chain, cod, Coefficients, Coordinates,
Component, ComponentList, d, 
ExteriorDerivative, ExteriorProduct, HomotopyOperator, Integral, 
InteriorProduct, InvertMetric, Laplace, LieDerivative, Metric, 
Pair, Pullback, Push, Restrict, Simple, Standard, HodgeStar, t, Tensor, 
TensorProduct, Wedge, X]


End[];

EndPackage[];

Print["Differential Forms package Version 4.0 by Frank Zizza"]
Print["with additions by Ulrich Jentschura.  For information "]
Print["about functions, Type ?DifferentialForms ."]
