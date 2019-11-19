# EE-utils
Perl GUI (GTK) examples for EE calculations

Some useful little EE calculators, intended to kind of replace the good old Shure slide rule for calculating reactance
problems, and ohm's law.
These are done in perl and GTK and serve as good exmples of how to use the stuff in the 
https://github.com/dcfusor/Perl_GUI repo.

The code is cleaner than some, naster than some.  No special effort was made to teach perl here, nor to make it hard
to figure out.  This is just how I write git 'er done fast throwaway perl code.

I put them in my home/doug/bin directory.  Your placement will be whatever you want - /usr/bin is more generic
I also provided icons which I put in /usr/share/gnome, and desktop files which you can put in 
home/yourname/.local/share/applications or wherever.  These can be created using the preferences/main menu
as well.  The locations of things must match whatever is in the desktop files, however you get there, and of course, the
actual utilities must be executable.

I find these actually useful now and then.  To use them, the general idea is to put in just enough known values to
allow the computation of the others. If you over-specify, you'll get an error warning, no big deal.

They look like this:
[ohms screenshot](https://github.com/dcfusor/EE-utils/blob/master/Ohms.png)
[reactance screenshot](https://github.com/dcfusor/EE-utils/blob/master/reactance.png)

