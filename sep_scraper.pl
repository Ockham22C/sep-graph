#!/usr/bin/perl
use warnings;
use strict;
use URI;

use WWW::Mechanize;
use HTML::TreeBuilder;

use Cwd qw(cwd);

my @input = @ARGV;
my @archives = ();

# add these to array to get different archived versions of the SEP
# win2018 fall2018 sum2018 spr2018 win2018 fall2017 sum2017 spr2017
# win2016 fall2016 sum2016 spr2016 win2015 fall2015 sum2015 spr2015 win2014 fall2014 sum2014 spr2014 win2013 fall2013 sum2013 spr2013 win2012 fall2012 sum2012 spr2012
# win2011 fall2011 sum2011 spr2011 win2010 fall2010 sum2010 spr2010 win2009 fall2009 sum2009 spr2009 win2008 fall2008 sum2008 spr2008 win2007 fall2007 sum2007 spr2007
# win2006 fall2006 sum2006 spr2006 win2005 fall2005 sum2005 spr2005 win2004 fall2004 sum2004 spr2004 win2003 fall2003 sum2003 spr2003 win2002 fall2002 sum2002 spr2002
# win2001 fall2001 sum2001 spr2001 win2000 fall2000 sum2000 spr2000 win1999 fall1999 sum1999 spr1999 win1998 fall1998 sum1998 spr1998 win1997 fall1997

# DONE::

sub user_input{
print "What year do you want to collect?\n";
my $year = <STDIN>;
chomp $year;
print "\nWhat season (spr,sum,fall,win)?\n";
my $season = <STDIN>;
chomp $season;
push @archives,$season.$year;
}

# user_input(); #un-comment to select your own season & year.

my @years   = qw(2013 2014 2015 2016 2017 2018);
my @seasons = qw(spr sum fall win);


my $location = cwd."\\data\\";

foreach (my $y = 0; $y < @years; $y++) {
	foreach (my $s = 0; $s < @seasons; $s++) {

		print "Collecting data from the ".$years[$y]." ".$seasons[$s]." edition of the SEP.\n";
		my $base = "http://plato.stanford.edu/archives/".$seasons[$s].$years[$y];
		my $article_list = $location.$years[$y]."_".$seasons[$s]."_node_list.csv";
		my $edge_list = $location.$years[$y]."_".$seasons[$s]."_edge_list.csv";
	  my $source_edge_list = $location.$years[$y]."_".$seasons[$s]."_source_edge_list.txt";
	  my $target_edge_list = $location.$years[$y]."_".$seasons[$s]."_target_edge_list.txt";

		open (NODES,">",$article_list) or die $!;
		open (EDGES,">",$edge_list) or die $!;
	#  open (SOURCE,">",$source_edge_list) or die $!;
	#  open (TARGET,">",$target_edge_list) or die $!;
	  print NODES "name,label\n";
	  print EDGES "source,target\n";
	#  print SOURCE "\n";
	#  print TARGET "\n";

		# scrape the archive for all article links
		my $start = WWW::Mechanize->new( autocheck => 1 );
		$start->get( $base ."/contents.html");

		my @article_urls;
		my @article_links = $start->find_all_links(url_regex => qr/entries/);

		# print all article (relative) links to document; these become nodes
		for (my $i = 0; $i < @article_links; $i++) {
			my $current_link = $article_links[$i]->url();
			my $current_node = $current_link;
			$current_node =~ s/entries\/(.*)\//$1/g;
			print NODES $current_node .",". $current_node ."\n";
			push (@article_urls,$current_link);
		}
		close NODES;

		# scrape the individual articles for their links
		for(my $i = 0; $i < @article_links; $i++) {
			my $article = WWW::Mechanize->new( autocheck => 1 );
			$article->get( $base ."/". $article_links[$i]->url());
			print $base . "/" . $article_links[$i]->url()."\n";
			my @edge_links = $article->find_all_links(url_regex => qr/\.{2}\/[\w-]+\/$/);
			if(@edge_links) {
	      foreach(@edge_links) {
					my $target_node = $_->url();
					if($target_node =~ /^\.{2}\/([\w-]+)((index\.html)?#\w*){0}\//){
	          my $source_node = $article_links[$i]->url();
	          $source_node =~ s/entries\/(.*)\//$1/g;
	          $target_node =~ s/\.{2}//g;
	          $target_node =~ s/index\.html//g;
	          $target_node =~ s/\#\w+//g;
	          $target_node =~ s/\/*//g; #ugh

	          my $s = $source_node;
	          my $t = $target_node;
	          #print "Link between ".$source_node." and ".$target_node."\n";

						print EDGES $s.",".$t."\n";
						#print SOURCE $s."\n";
						#print TARGET $t."\n";
					}
				}
			}
		}

		close EDGES;

	}
}
