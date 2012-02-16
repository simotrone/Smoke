<img src="https://lh3.googleusercontent.com/-W4b-7B0iMFw/Tz1johaJplI/AAAAAAAAAhg/-GwogT937rI/s982/smoke.jpg">

This file documents the revision history for Perl extension Smoke.


First version: 2010-11-09 21:51:56

## Use

A lot of this work is made to study Catalyst and try a fast way to show photos from mobile phone.

I take a pic with mobile phone, upload on picasa albums, and website gallery show it. It works.


## Modules used

+ Catalyst project
+ Template::Toolkit
+ XML::Atom::Feed to manage Picasa images
+ Moose
+ DBI
+ PostgreSQL
+ javascript 
	+ Ajax (see root/template/wrapper)
	+ jquery framework


## Minimal description


I have also Pg backend for Quotes and Links and DBI interface writes ad-hoc.


### XML::Feed benchmarks

Working on this webapp I found some interesting result with xml feeds (RSS/Atom).

Atom module is really more fast...

    sim@idrogeno:~/dev/perl/xml$ perl test_parser.pl
               (warning: too few iterations for a reliable count)
                    Rate xml_rss_libxml    default_rss        xml_rss  default_atom
    xml_rss_libxml 1.79/s             --            -0%            -0%         -100%
    default_rss    1.79/s             0%             --            -0%         -100%
    xml_rss        1.79/s             0%             0%             --         -100%
    default_atom    667/s         37147%         37120%         37113%            --
    
    sim@idrogeno:~/dev/perl/xml$ cat test_parser.pl
    #!/usr/bin/perl
    
    use strict;
    use warnings;
    use XML::Feed;
    use Benchmark;
    
    Benchmark::cmpthese( 100, {
       "default_rss" => sub {
           XML::Feed->parse("simotrone_feed_rss.xml"),
       } ,
       "default_atom" => sub {
           XML::Feed->parse("simotrone_feed_atom.xml"),
       } ,
       "xml_rss" => sub {
           $XML::Feed::RSS::PREFERRED_PARSER = "XML::RSS";
           XML::Feed->parse("simotrone_feed_rss.xml");
       },
       "xml_rss_libxml" => sub {
           $XML::Feed::RSS::PREFERRED_PARSER = "XML::RSS::LibXML";
           XML::Feed->parse("simotrone_feed_rss.xml");
       },
    } );


                  Rate XML RSS-ATOM XML ATOM-RSS
    XML RSS-ATOM 33.4/s           --         -13%
    XML ATOM-RSS 38.5/s          15%           --
