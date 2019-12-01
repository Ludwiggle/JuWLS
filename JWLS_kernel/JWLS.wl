#!/usr/bin/env wolframscript

______________________________________________________________________

(* This section parses command line arguments *)

argv = Rest@$ScriptCommandLine;
argc = Length@argv;

(* Default value *)
$JWLSnbTmp = "/tmp/JWLS";

unrecognized =
  (* Use ReplaceAll to parse arguments from beginning of argv. *)
  argv //.
    {

      (* For robustness, translate from {"--arg=value"} syntax
         to {"--arg", "value"} syntax. *)
      {argEqVal_, rest___} /; (
        (* Construct a list of matches of the form --arg=value and put
           them in the form {"--arg", "value"}. *)
          matches =
            StringCases[argEqVal,
              RegularExpression["--([^=]+)=(.*)"] :> {"--$1", "$2"}];
              (* There should only be one such match. *)
              Length[matches] == 1
      ) :>
       (* Replace the single match while preserving the rest of the
          list. *)
       Join[matches[[1]], {rest}],

      {"--url",    val_, rest___} :> ($JWLSnbURL = val; {rest}),
      {"--tmpdir", val_, rest___} :> ($JWLSnbTmp = val; {rest})
    };

(* Throw error if something left over. *)
If[Length[unrecognized] > 0,
  Print["Unrecognized arguments from: ", StringRiffle[unrecognized]];
  Exit[1]
];

(* Delete temporary variables *)
matches =.;
unrecognized =.;

Print[$JWLSnbURL];
Print[$JWLSnbTmp];

______________________________________________________________________


(* Lazily-evaluated notebook URL function which starts
   notebook as needed. *)
JWLSnbAddrF := ReadString@"!jupyter notebook list"~
           StringCases~Shortest["http://"~~__~~"/"]//
           If[# == {}
               ,(Print["\n$:"<>#]; Run@#)& @"jupyter notebook &";
                 Pause@1; JWLSnbAddrF
               ,Print["\n~: "<>First@#]; First@#<>"files/"
             ]&;

(* If URL is specified from command line, then use that.
   Otherwise, run the function above. *)
If[ValueQ[$JWLSnbURL],
  $JWLSnbAddr = $JWLSnbURL,
  $JWLSnbAddr = JWLSnbAddrF
];

______________________________________________________________________


$JWLSgraphicsBaseName := ($JWLSnbTmp <> "/output_files/" <> IntegerString[Hash[#], 36])&;

show@g_Image := "echo "<>$JWLSnbAddr<>"/"<>FileNameTake@Export[$JWLSgraphicsBaseName[g] <> ".png",g,"PNG"]//
                 (Run@#; Return@Last@StringSplit@#)&;

show@g_ := "echo "<>$JWLSnbAddr<>"/"<>FileNameTake@Export[$JWLSgraphicsBaseName[g] <> ".pdf",g,"PDF"]//
           (Run@#; Return@Last@StringSplit@#)&;

show@g_Graphics3D := "wolframplayer -nosplash " <> 
                      Export[$JWLSgraphicsBaseName[g] <> ".nb",g] // Run;


Protect@show;

$PrePrint = Shallow[ #,{Infinity,12}]&;

______________________________________________________________________


SetOptions[$Output,FormatType->OutputForm, PageWidth->120];


JWLSghostRun := ($lastRes=%; Run@#; $Line = $Line-1; $lastRes; Return[])&;

JWLSemptylogF := JWLSghostRun["> "<>Streams[][[1,1]]];

JWLScatoutF := JWLSghostRun["cat "<>Streams[][[1,1]]<>" > " <> $JWLSnbTmp <> "/wlout.txt"];

______________________________________________________________________


$Line = 0;
Dialog[];
