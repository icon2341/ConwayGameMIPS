#
# Makefile for CompOrg Final Project -Colony
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out


#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Object files
#
#OBJFILES = sub_strings.obj sub_ascii_numbers.obj
OBJFILES = Colony.obj is_location_taken.obj print_board.obj

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -m -o $*.out $*.obj > $*.map

#
# Main target
#
Colony.out:	$(OBJFILES)
	$(RLINK) -m -o $*.out $(OBJFILES) > $*.map
