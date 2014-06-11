all: html

html:
	. test/service.env && ./opsview-html-email.js service | awk 'NR > 5' > service.html
	. test/host.env && ./opsview-html-email.js host | awk 'NR > 5' > host.html

clean:
	rm -f *.html
