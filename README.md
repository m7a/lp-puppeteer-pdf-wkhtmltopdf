---
section: 32
x-masysma-name: puppeteer-pdf-wkhtmltopdf
title: WKHTMLTOPDF Alternative using Puppeteer-PDF
date: 2025/08/17 16:56:00
lang: en-US
author: ["Linux-Fan, Ma_Sys.ma (info@masysma.net)"]
keywords: ["mdvl", "wkhtmltopdf", "puppeteer-pdf"]
x-masysma-version: 1.0.0
x-masysma-website: https://masysma.net/32/puppeteer-pdf-wkhtmltopdf.xhtml
x-masysma-repository: https://www.github.com/m7a/lp-puppeteer-pdf-wkhtmltopdf
x-masysma-owned: 1
x-masysma-copyright: (c) 2025 Ma_Sys.ma <info@masysma.net>
---
Abstract
========

WKHTMLTOPDF is a tool that can be used to convert websites (HTML) into PDF in
a non-interactive manner. It uses a QT-integrated browser engine based on
Webkit for the rendering. With the switch to Debian 13 (Trixie), package
`wkhtmltopdf` was removed from Debian stable. It had long been based on
unmaintained technology, the details of which are explained on tool's homepage
at <https://wkhtmltopdf.org/status.html>.

This repository and page explore alternatives and attempt to create a
“drop-in” replacement for common Ma_Sys.ma use cases.

Alternatives to WKHTMLTOPDF
===========================

There is no obvious replacement for WKHTMLTOPDF available in Debian. While it is
possible to invoke a Webbrowser to export to PDF, the options to configure the
output (e.g.  page size etc) from a script are very limited.

For example:

	chromium --headless --disable-gpu --no-pdf-header-footer --print-to-pdf=masysma.net.pdf https://masysma.net

While this indeed creates a PDF, not even a custom page size cannot be set via
the command line. The general approach of using a headless browser seems to
still be the best bet when looking for an alternative to WKHTMLTOPDF. In order
to get more options, a tool interfacing using the web browser's own API is
required.

## Introducing Puppeteer

For Chromium, the recommended tool that can do this seems to be Puppeteer
(<https://pptr.dev/>). Puppeteer is a JavaScript library (NodeJS) that exposes
the web browser's API in a unified manner.

Unfortunately, Puppeteer is not part of Debian. Also, it is not a commandline
tool that could be used as a replacement for the `wkhtmltopdf` command.

## Puppeteer-PDF

The second issue is addressed by the tool `puppeteer-pdf`
(<https://github.com/Contractbook/puppeteer-pdf>) which is a NodeJS-based
JavaScript tool that can be invoked via the CLI and which exposes a command line
interface similar to WKHTMLTOPDF albeit with different naming for the options.

This leaves “only” the problem how to get these tools running on a Debian system
in a reasonable manner.

Running Puppeteer-PDF on Debian
===============================

The minimal steps required to run puppeteer-pdf on Debian are as follows:

	git clone https://github.com/Contractbook/puppeteer-pdf.git
	cd puppeteer-pdf
	npm install
	CHROME_BIN=/usr/bin/chromium ./puppeteer-pdf.js -p masysma.net.pdf https://masysma.net

This approach downloads _all_ of the dependencies (about 120 NPM packages and
250 MiB of disk storage) from NPM and assembles them in a local `node_packages`
directory.

This is sad because more than half of the dependencies are also available in
the Debian repositories, but they don't integrate into this approach to running
a NodeJS program at all. Also, why is there need for 120 packages (and in sum
not even small ones!) just to invoke some browser API to do a website to PDF
conversion with more parameters than natively offered by the Browser itself?

As not all of the dependencies are in Debian, some of the packages must be
downloaded from NPM but it seems there is no way to easily tell NPM to prefer
obtaining the _available subset_ of packages from Debian rather than NPM?

The build instructions contained in this repository encode a hack as follows:

 1. Initially, `npm install` is called and all is downloaded from NPM
 2. Available packages on a Debian system are identified (manually!) and the
    downloaded copies are replaced by symlinks to the Debian system wherever
    possible.
 3. The remainder of downloaded and not replaced packages is checked against a
    known list to avoid unexpected additional new dependencies sneaking in.

This way, as much as possible is used from the Debian system while using NPM to
download the remainder of packages. The bulk of the data required is shared with
the system (> 200 MiB) and the remainder (~ 35 MiB) is downloaded from NPM and
installed in a tool-specific `node_modules` directory on the Debian system.

If you want to follow this approach, check the `build.xml` and
`replace_downloads_by_os_packages.sh` scripts in the repository for the
respective instructions. If all the necessary dependencies are present on the
system, the build can be triggered as follows:

	ant package

WKHTMLTOPDF Compatibility Layer
===============================

As there are some scripts which expect the WKHTMLTOPDF syntax and as I am not
sure if the Puppeteer-based approach is going to be a stable solution for a long
time, I have prepared an additional script `wkhtmltopdf` that maps my most
commonly used WKHTMLTOPDF options to the appropriate `puppeteer-pdf`
invocations. Notably, it also attempts to reproduce the defaults of WKHTMLTOPDF
here.

It currently supports the following invocation:

	USAGE wkhtmltopdf [OPTIONS] <IN-URL> <PDF-FILE>
	
	OPTIONS:
	  -O|--orientation Portrait|Landscape
	  -s|--page-size A4
	  -B|--margin-bottom 10mm
	  -L|--margin-left 10mm
	  -R|--margin-right 10mm
	  -T|--margin-top 10mm
	  --background
	  --no-background
	  --page-height 297mm
	  --page-width 210mm
	
	IN-URL:
	  Page to process. It may be a local file name, too.
	
	PDF-FILE:
	  Output to write PDF file to.

Conclusion
==========

This is a hack, but it works around a hard issue when upgrading from Debian 12
to Debian 13 and might also help other people struggling to get an alternative
to WKHTMLTOPDF running.

Future Directions
=================

The hack could be turned into a proper solution by packaging all of the (~ 30)
missing NPM dependencies (and ultimately puppeteer-pdf itself) for Debian.

Another extension could be to introduce a replacement for `wkhtmltoimage`, too.

See Also
========

About WKHTMLTOPDF

 * <https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1091821>
 * <https://wkhtmltopdf.org/status.html>

About Pupeteer-PDF

 * <https://github.com/Contractbook/puppeteer-pdf>

Alternatives to WKHTMLTOPDF

 * <https://stackoverflow.com/questions/52379104/alternative-to-wkhtmltopdf>
 * <https://gotenberg.dev/> - if the approach using a local browser blows up,
   maybe it is time to run a server to encapsulate the functionality. It is much
   more a heavyweight approach compared to a one-off script invocation, though.
