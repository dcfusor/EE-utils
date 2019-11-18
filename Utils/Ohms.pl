#!/usr/bin/perl

# Here we go again...GPLv2 will do C 2017 Doug Coulter
# as usual, if I thought it dodgy, I used @@@ in a nearby comment

use Modern::Perl '2014'; # we only have 5.18 on this machine?
use File::Basename 'dirname'; # for knowing where we are (ease for developer) already here
use Gtk3 -init; # for our GUI
use Glib  qw(TRUE FALSE); # for periodic events etc
#use Gtk3::Helper; # allows us to add "watch" callbacks to handles?
#http://askubuntu.com/questions/319568/i-cant-configure-rhythmbox-as-gobject-introspection-1-is-not-installed for when you can't install gtk3 or glib
#

#use Storable qw(nstore retrieve); # for (re) storing hash of hashes preset
#use DBI; # for mySQL interface
####################################################################
# GUI variable references to objects
my $GUIFilename = '/Ohms.glade'; # use your real filename here

my $builder = Gtk3::Builder->new(); # gtkbuilder object, creates a gui from glade's xml
my $mainwin; # will be set up in the creation routine
# put references to any other new created gui objects here for organization

my ($Er,$E); # reference to voltage text box, voltage variable
my ($Ir,$I);
my ($Rr,$R);
my ($Pr,$P);
my $Dr;

####################################################################
# @@@ this has a hardcoded glade filename - you need to fix that as required

sub createguifile # create the gui from xml in a .glade file 
{ # use this for developer convienience.  Final product should put glade xml
  # after the __END__ tag and use createguilocal instead
 $builder->add_from_file(dirname($0) . $GUIFilename); # @@@ set that variable right, dumb ass
 $mainwin = $builder->get_object('mainwin'); #@@@ assumes main window is called mainwin
 $builder->connect_signals(undef);
 $mainwin->set_screen( $mainwin->get_screen() ); #??? from an example.  Seems redundant?
 $mainwin->signal_connect(destroy => sub {Gtk3->main_quit});
 $mainwin->show_all();
# not so program-specific you couldn't use it again
}
####################################################################
# switch to using this once the gui is more or less settled - the file is easier to change
# but this is easier to ship.
sub createguilocal # create the gui from xml in a .glade file 
{ # put glade xml after the __END__ tag and use createguilocal
 my $guidata; # packed the xml internally, goes here
 local $/; # which makes this undefined for this sub
 $guidata = <main::DATA>; # which makes this slurp the entire "file"
 $builder = Gtk3::Builder->new_from_string($guidata,length($guidata));
 $mainwin = $builder->get_object('mainwin'); #@@@ assumes main window is called mainwin
 $builder->connect_signals(undef);
 $mainwin->set_screen( $mainwin->get_screen() ); #??? from an example.  Seems redundant?
 $mainwin->signal_connect(destroy => sub {Gtk3->main_quit});
 $mainwin->show_all();
}
####################################################################
sub getGUIrefs
{ # get pointers to the widgets, erm, references, whatever
	$Er = $builder->get_object('E');
	$Ir = $builder->get_object('I');
	$Rr = $builder->get_object('R');
	$Pr = $builder->get_object('P');
	$Dr = $builder->get_object('dialog1');
	$Dr->set_transient_for($mainwin); # window to be on top of, avoids warning too
}
####################################################################
sub GUI2var
{# get whatever is in the text boxes
 $E = $Er->get_text();
 $I = $Ir->get_text();
 $R = $Rr->get_text();
 $P = $Pr->get_text();  
}
####################################################################
sub var2GUI
{ # put whatever we think we know into text boxes
 $Er->set_text($E);
 $Ir->set_text($I);
 $Rr->set_text($R);
 $Pr->set_text($P);
}
####################################################################
sub clearVars
{ # make them all nothing (not null, but close)
	$E = $I = $R = $P = '';
	var2GUI(); # update the gui to show this
}
####################################################################
sub DoCalc
{ # variable indentation to drive python people mad, because I can.
#	say "calc clicked";
 	return if CheckInput();
 	$E ||= 0; # force all these guys to numeric
 	$I ||= 0; # avoids warnings
	$R ||= 0;
 	$P ||= 0;

if($E !=0)
 {
  if($I !=0)
  {	
   $R=$E/$I;
   $P=$E*$I;				
  }
elsif ($R !=0)
 {
  $I=$E/$R;
  $P=($E*$E)/$R;				
  }
elsif ($P !=0)
 {
  $I=$P/$E;
  $R=($E*$E)/$P;				
 }
 var2GUI();			
 return; 
 }

 if($I !=0)
{
if ($R !=0)
{				
$E=$I*$R;
$P=($I*$I)*$R;				
}
elsif ($P !=0)
{		
$E=$P/$I;
$R=$P/($I*$I);			
}
var2GUI();
return;
}

$I=sqrt($P/$R);
$E=sqrt($P*$R);			
var2GUI();
return;
# adapted from tricksy javascript, I didn't optimize for fewer keystrokes by the programmer
}
####################################################################
sub CheckInput
{ # make sure two and only two values are set, else do error dialog,
  # which will clear stuff
 my $input_count = 0;
 $input_count++ unless ($E eq '');
 $input_count++ unless ($I eq '');
 $input_count++ unless ($R eq '');
 $input_count++ unless ($P eq '');

 unless ($input_count == 2) # do the error dialog
 {
 	$Dr->show_all();
 	return 2; 
 }
 return 0; # for giggles
}
####################################################################
sub on_dialogOKbutton_clicked
{
	#say "dialog ok button";
	clearVars();
	$Dr->hide();
}
####################################################################
sub on_CALC_clicked
{
	GUI2var(); # Get User Input - punny acronym
	DoCalc();
}
####################################################################
sub on_RST_clicked
{
 clearVars();
 var2GUI();	
}
####################################################################
sub initialize 
{ # put all your init code here
#	createguifile(); # you'll start out with this
	createguilocal();
	getGUIrefs();
}
####################################################################


####################################################################
############################ Main ##################################
####################################################################

initialize();
#say "Compiled OK."; # way to say we made it.
 Gtk3->main; # GUI event forever loop - when we quit, we fall out and exit

# when your gui is settled, copy the xml from the glade file to below the end tag and use createguilocal
#instead.  Harder to change, easier to ship.  You can extract this back into some file named with .glade
# at the end to use the glade editor on it later on.
 __END__
<?xml version="1.0" encoding="UTF-8"?>
<!-- Generated with glade 3.18.3 -->
<interface>
  <requires lib="gtk+" version="3.12"/>
  <object class="GtkDialog" id="dialog1">
    <property name="name">dialog1</property>
    <property name="can_focus">False</property>
    <property name="tooltip_text" translatable="yes">You are seeing this crap because you didn't fill in two and only two entries before hitting calculate.  Clicking OK will clear all the entires out so you can try again.</property>
    <property name="modal">True</property>
    <property name="destroy_with_parent">True</property>
    <property name="type_hint">dialog</property>
    <child internal-child="vbox">
      <object class="GtkBox" id="dialog-vbox1">
        <property name="can_focus">False</property>
        <property name="tooltip_text" translatable="yes">You are seeing this crap because you either didn't fill in enough, or filled in too many entries!  Just 2, please - any two.</property>
        <property name="orientation">vertical</property>
        <property name="spacing">2</property>
        <child internal-child="action_area">
          <object class="GtkButtonBox" id="dialog-action_area1">
            <property name="can_focus">False</property>
            <property name="layout_style">end</property>
            <child>
              <placeholder/>
            </child>
            <child>
              <object class="GtkButton" id="dialogOKbutton">
                <property name="label" translatable="yes">OK</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">True</property>
                <property name="tooltip_text" translatable="yes">Clears all the entries so you can try again.  Fill in two and only two.  Three thou shall not fill, neither one, except on the way to two.</property>
                <property name="xalign">0.49000000953674316</property>
                <signal name="clicked" handler="on_dialogOKbutton_clicked" swapped="no"/>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
                <property name="position">1</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">False</property>
            <property name="position">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label7">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Input only two values!</property>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">True</property>
            <property name="position">1</property>
          </packing>
        </child>
      </object>
    </child>
  </object>
  <object class="GtkApplicationWindow" id="mainwin">
    <property name="name">mainwin</property>
    <property name="can_focus">False</property>
    <property name="tooltip_text" translatable="yes">Ohms law and power calculator.  Enter two and only two values into the boxes, and click calculate.  We'll do the rest.</property>
    <property name="title" translatable="yes">Ohms</property>
    <child>
      <object class="GtkGrid" id="grid1">
        <property name="visible">True</property>
        <property name="can_focus">False</property>
        <child>
          <object class="GtkLabel" id="label1">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Ohm's law and power calculator:  </property>
          </object>
          <packing>
            <property name="left_attach">1</property>
            <property name="top_attach">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label2">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Supply two known values</property>
          </object>
          <packing>
            <property name="left_attach">2</property>
            <property name="top_attach">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkEntry" id="E">
            <property name="name">E</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="tooltip_text" translatable="yes">Volts, in um, volts.</property>
            <property name="primary_icon_tooltip_text" translatable="yes">The value in volts.</property>
            <property name="input_purpose">number</property>
          </object>
          <packing>
            <property name="left_attach">1</property>
            <property name="top_attach">1</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label3">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Volts</property>
          </object>
          <packing>
            <property name="left_attach">2</property>
            <property name="top_attach">1</property>
          </packing>
        </child>
        <child>
          <object class="GtkEntry" id="I">
            <property name="name">I</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="tooltip_text" translatable="yes">Current in amperes</property>
            <property name="primary_icon_tooltip_text" translatable="yes">Current in Amperes</property>
            <property name="input_purpose">number</property>
          </object>
          <packing>
            <property name="left_attach">1</property>
            <property name="top_attach">2</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label4">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Amperes</property>
          </object>
          <packing>
            <property name="left_attach">2</property>
            <property name="top_attach">2</property>
          </packing>
        </child>
        <child>
          <object class="GtkEntry" id="R">
            <property name="name">R</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="tooltip_text" translatable="yes">Restance or Z in ohms, and it's not futile.</property>
            <property name="primary_icon_tooltip_text" translatable="yes">Resistance or Z in ohms</property>
            <property name="input_purpose">number</property>
          </object>
          <packing>
            <property name="left_attach">1</property>
            <property name="top_attach">3</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label5">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Ohms</property>
          </object>
          <packing>
            <property name="left_attach">2</property>
            <property name="top_attach">3</property>
          </packing>
        </child>
        <child>
          <object class="GtkEntry" id="P">
            <property name="name">P</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="tooltip_text" translatable="yes">Power, in watts, or joules per second if you're weird.</property>
            <property name="primary_icon_tooltip_text" translatable="yes">Power, in watts</property>
            <property name="input_purpose">number</property>
          </object>
          <packing>
            <property name="left_attach">1</property>
            <property name="top_attach">4</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label6">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="tooltip_text" translatable="yes">Power in watts, or joules per second.</property>
            <property name="label" translatable="yes">Watts</property>
          </object>
          <packing>
            <property name="left_attach">2</property>
            <property name="top_attach">4</property>
          </packing>
        </child>
        <child>
          <object class="GtkButton" id="RST">
            <property name="label" translatable="yes">Reset</property>
            <property name="name">RST</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="receives_default">True</property>
            <property name="tooltip_text" translatable="yes">Clear all the entry boxes.</property>
            <signal name="clicked" handler="on_RST_clicked" swapped="no"/>
          </object>
          <packing>
            <property name="left_attach">1</property>
            <property name="top_attach">5</property>
          </packing>
        </child>
        <child>
          <object class="GtkButton" id="CALC">
            <property name="label" translatable="yes">Calculate</property>
            <property name="name">CALC</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="receives_default">True</property>
            <property name="tooltip_text" translatable="yes">Click to calculate unknowns from any two known values.</property>
            <property name="xalign">0.40000000596046448</property>
            <signal name="clicked" handler="on_CALC_clicked" swapped="no"/>
          </object>
          <packing>
            <property name="left_attach">2</property>
            <property name="top_attach">5</property>
          </packing>
        </child>
        <child>
          <placeholder/>
        </child>
        <child>
          <placeholder/>
        </child>
        <child>
          <placeholder/>
        </child>
        <child>
          <placeholder/>
        </child>
        <child>
          <placeholder/>
        </child>
        <child>
          <placeholder/>
        </child>
      </object>
    </child>
  </object>
</interface>
