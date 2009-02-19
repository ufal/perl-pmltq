### Makefile --- 

## Author: pajas@ufal.ms.mff.cuni.cz
## Version: $Id: Makefile,v 0.0 2008/09/27 07:08:36 pajas Exp $
## Keywords: 
## X-URL: 

XSL=http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl

.PHONY: clean rails all html tex

all: rails html

html: pmltq_doc.html

htmltex: pmltq_doc.html tex

tex: tex-math-equations.tex
	latex tex-math-equations.tex
	dvi2bitmap --resolution=600 --scaledown=5 tex-math-equations.dvi

rails: pmltq_doc.xml mk_rail.sh mk_rails.xsh
	./mk_rails.xsh pmltq_doc.xml

pmltq_doc.html: pmltq_doc.xml
	xsltproc --xinclude \
	   --stringparam use.role.for.mediaobject 1 \
           --stringparam preferred.mediaobjectrole html \
           --stringparam html.stylesheet blue.css \
           --stringparam tex.math.in.alt latex \
        -o pmltq_doc.html $(XSL) pmltq_doc.xml 

clean:
	rm pmltq_doc.html
	rm -f rail_*.log  rail_*.aux rail_*.tex rail_*.rao rail_*.rai rail_*.pdf

### Makefile ends here
