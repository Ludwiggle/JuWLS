# JWLS

A **J**upyter notebook for **W**olfram**L**anguage**S**cript

Designed to provide a responsive HTML interface to a remote WolframScript interpreter. 

Run `JWLS.sh`


### Features

JWLS is a slimmed down version of the [`bash_kernel`](https://github.com/takluyver/bash_kernel) 
that transfer Wolfram Language expressions to a [WolframKernel](https://www.wolfram.com/cdf-player/) 
through the WolframScript interface. 

Graphics is rendered by the Jupyter file viewer, not by notebook.
`Show` returns the URL of the graphical output.


The `Out[..]` expressions are returned on both the Jupyter notebook and the terminal where JWLS is started; though error messages, symbols `Information` and progress indicators are printed on terminal only.

![](JWLSrec.gif)

The underlying `bash_kernel` is still accessible by starting a cell with `!`

![](bashCell.gif)




### How it works

The `JWLS.sh` script reads your `jupyter notebook list` to take note of the **first** notebook URL found; if Jupyter is not running, JWLS will start a new notebook. 

The WolframKernel is then initiated in REPL mode waiting for commands sent by the `bashWL_kernel.py` through a temporary fifo.
By default, wolframscript would append ouputs on a temporary log file; JWLS simply pipes the latest ouputs from that file back to Jupyter. 

