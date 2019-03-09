if !has("nvim")
	" Change Font
	if has("gui_win32")
		set guifont=Consolas:h11:cANSI
	endif
	set guioptions-=T " Remove toolbar
	set guioptions-=m " Remove menu
else
	" Remove tab line
	GuiTabline 0 
	" Remove tab line
	GuiPopupmenu 0 
endif
