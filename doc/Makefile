### Makefile --- 

## Author: pajas@ufal.ms.mff.cuni.cz
## Version: $Id: Makefile,v 0.0 2008/09/27 07:08:36 pajas Exp $
## Keywords: 
## X-URL: 

.PHONY: clean

pmltq_doc.html: pmltq_doc.xml mk_rail.sh mk_rails.xsh
	./mk_rails.xsh pmltq_doc.xml
	xsltproc --xinclude --stringparam use.role.for.mediaobject 1 --stringparam preferred.mediaobjectrole html --stringparam html.stylesheet blue.css -o pmltq_doc.html http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl pmltq_doc.xml 

clean:
	rm pmltq_doc.html
	rm rail_*.*

### Makefile ends here
