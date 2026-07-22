(*

Difform

A Mathematica package for differential form algebra
By Joerg Enderlein
Email: jenderl@gwdg.de
www: https://www.joerg-enderlein.de

Copyright 2018 Joerg Enderlein
All rights reserved

Mathematica is a registered trademark of Wolfram Research, Inc.

This software package and its accompanying documentation are provided as is, without guarantee of support or maintenance. The copyright holder makes no express of implied warrenty of any kind with respect to this software, including implied warrenties of merchantability or fitness for practical purpose, and is not liable for any damages resulting in any way from its use.

Everyone is granted permission to copy, modify and redistribute this software package and its accompanying documentation, provided that:
1.	All copies contain this notice in the main program file and in the supporting documentation.
2.	All modified copies carry a prominent notice stating who made the last modification and the date of such modifiction.
3.	No charge is made for this software or works derived from it, with the exception of a distribution fee to cover the cost of materials and/or transmission.

*)

BeginPackage["Difform`", "Global`"]

Difform::usage = "Difform.m is a package for working with differential forms."

Coord::usage = "Coord are the actual coordinates."

Basis::usage = "Basis defines the basis 1-forms."

Metric::usage = "Metric is the actual metric corresponding to the choosen basic 1-forms."

InvMetric::usage = "InvMetric is a variable giving the inverse of Metric. See also MakeMetricSpace."

InvBasis::usage = "InvBasis is a variable defining the basis vectors. See also MakeMetricSpace."

VolumeElement::usage = "VolumeElement is a variable defining the volume of a parallelepiped, the edges of which are the n basis vectors (in n dimensions). See also MakeMetricSpace."

Diff::usage = "Diff[x] gives the differential derivative of x."

WedgeProd::usage = "WedgeProd[x,y] gives the exterior product of x with y."

Hodge::usage = "Hodge[x] applies the Hodge star operator to x."

Components::usage = "Components[x] returns a matrix of the components of a differential form x."

MakeMetricSpace::usage = "MakeMetricSpace[(sig)] computes InvMetric, InvBasis and VolumeElement, which are necessary for calculating the affinity 1-forms and curvature tensors."

Omega::usage = "Omega[] returns the affinity 1-forms provided that the basis 1-forms and the metric are defined by Basis and Metric."

Riemann::usage = "Riemann[x] returns the components of the Riemann tensor, where x are the components of the affinity 1-forms."

Ricci::usage = "Ricci[x] returns the components of the Ricci tensor, where x are the components of the Riemann tensor."

Einstein::usage = "Einstein[x] returns the components of the Einstein tensor, where x are the components of the Ricci tensor."

Begin["`Private`"]

Hide[c_?NumberQ] := c;
SetAttributes[Hide, {Listable, Constant}];

CollectCases[exp_, h_] := Collect[exp, Cases[exp, h, Infinity] // Union];

Diff[a_] := Diff[CollectCases[a, Literal[Diff[__]]]] /; 
	a=!=CollectCases[a, Literal[Diff[__]]];
Diff[a_ + b_] := Diff[a]+Diff[b];
Diff[a__]:=0 /; Union[List[a]] =!= Sort[List[a]];
Diff[b_ Diff[a__]]:=Sum[D[ b,Coord[[i]] ] Diff[Coord[[i]],a], 
{i,Length[Coord]}];
Diff[b___,a_,c___]:=Sum[D[a,Coord[[i]]] Diff[b,Coord[[i]],c], 
{i,Length[Coord]}] /; FreeQ[Coord,a];
Diff[a__] := Signature[List[a]] Diff @@ Sort[List[a]] /;
List[a] =!= Sort[List[a]];
Diff[] := 1;

SetAttributes[Diff, Listable];

WedgeProd[x_, y_] := WedgeProd[Expand[x],Expand[y]] /; (x=!=Expand[x] && y=!=Expand[y]);
WedgeProd[x_ + y_, z_] := WedgeProd[x, z]+WedgeProd[y, z];
WedgeProd[x_, y_ + z_] := WedgeProd[x, y]+WedgeProd[x, z];
WedgeProd[a_ Diff[x__], y_] := a WedgeProd[Diff[x],y];
WedgeProd[x_, a_ Diff[y__]] := a WedgeProd[x, Diff[y]];
WedgeProd[Diff[x__],Diff[y__]] := Diff[x,y];

MakeMetricSpace[sig_:1] := 
Module[{},
InvMetric = Simplify[Inverse[Metric],Trig->False];
InvBasis = Simplify[Inverse[Basis],Trig->False];
VolumeElement = Simplify[Sqrt[sig Det[Metric]]];
];

Hodge[a_+b_] := Hodge[a] + Hodge[b];
Hodge[a_] := a (Diff @@ Coord) /; FreeQ[a,Diff];
Hodge[a_ Diff[b__]] := a Hodge[Diff[b]];
Hodge[x_] := Module[{forwardrule, backrule, tmp},
forwardrule = Thread[Coord->Hide[InvBasis.InvMetric].Coord];
backrule = Thread[Coord->(Hide[Basis].Coord)];
tmp = x /. Literal[Diff[a__]]:>(Diff @@ (List[a] /. forwardrule));
tmp = tmp /. Literal[Diff[a__]]:>
Signature[Flatten[{a,Complement[Coord,{a}]}]] Signature[Coord]*
(Diff @@ (Complement[Coord,{a}] /. backrule));
VolumeElement tmp /. Hide[v_]:>v];

Components[x_] := 
Module[{tmp, tmprule, ml, mat, len = Length[Coord]},
ml = Cases[{x},Diff[__],Infinity] /. Diff[v__] :> Length[List[v]] // Union;
If[ml=!={},
ml = ml[[1]];
mat = Nest[Table[#,{len}]&,0,ml];
tmprule = Thread[Coord->(Hide[InvBasis].Coord)];
tmp = x /. Diff[v__]:>Diff @@ (List[v] /. tmprule);
tmp = CollectCases[tmp /. Hide[v_]:>v, Literal[Diff[__]]];
tmp = tmp /. 
(Diff[v__]:>ReplacePart[mat, 1, List[v] /. Thread[Coord->Table[i,{i,len}]]]);
Plus @@ ((Signature[#] Transpose[tmp,#])& /@ Permutations[Table[i,{i,ml}]]),
x]
];

Omega[] := 
Module[{tmp1, tmp2, len=Length[Coord]},
tmp1 = Components /@ (Diff /@ (Basis.(Diff /@ Coord)));
tmp1 = If[#===0, Table[0,{len},{len}],#]& /@ tmp1;
tmp1 = Metric.tmp1;
tmp1 = tmp1-Transpose[tmp1]-Transpose[tmp1,{3,1,2}];
tmp2 = 
Map[(InvBasis.Table[D[#,Coord[[i]]],{i,Length[Coord]}])&, Metric, {2}];
tmp2 = tmp2+Transpose[tmp2,{1,3,2}]-Transpose[tmp2,{2,3,1}];
InvMetric.(tmp1+tmp2)/2
];

Riemann[omega_] := 
Module[{tmp,tpp,len = Length[Coord]},
tmp = Map[Components[Diff[#.Basis.(Diff /@ Coord)]]&,omega,{2}];
tmp + Table[
tpp=Sum[Outer[Times,omega[[i,j]],omega[[j,k]]],{j,len}];
tpp-Transpose[tpp], {i,len},{k,len}]
];

Ricci[riemann_] := 
InvMetric.TensorContract[riemann,{1,3}];

Einstein[ricci_] := 
ricci-IdentityMatrix[Length[Coord]]*Tr[ricci]/2;

End[]

Protect[Diff, Wedge, Hodge, Components, MakeMetricSpace, Omega, Riemann, Ricci, Einstein]

EndPackage[]
