@echo off
setlocal enabledelayedexpansion

:: Hashcatalyst v1.0 by Will Hunt @Stealthsploit
:: https://in.security/
:: In.security Discord https://discord.gg/5VpwE9YJ9R

:: Ensure file paths are set
:: Hash list
set hash_list=C:\path\to\hashlist.txt
:: Hashcat algorithm mode, e.g. 0 for MD5
set hashcat_mode=0
:: Potfile to store cracked hashes
set potfile_path=C:\path\to\hashcat.potfile
:: Single wordlist for use in attacks 2,4,6,7,8,14
set wordlist=C:\path\to\primary_wordlist.txt
:: Rule file for attacks 6,9 and primary rule file for attack 7,10
set rule_file=C:\path\to\primary_rule.rule
:: All *.rule files here used in attacks 8,11
set rule_folder=C:\path\to\rules_folder
:: Nested rule file in attacks 7,10
set nested_rulefile=C:\path\to\nested_rule.rule
:: All *.txt files here used in attacks 3,5,9,10,11,15
set wordlist_dir=C:\path\to\multiple_wordlists
:: First list for combinator in attacks 12,13
set combi_list1=C:\path\to\combilist1.txt
:: Second list for combinator in attacks 12,13
set combi_list2=C:\path\to\combilist2.txt
:: Rule file for use in attack 13
set combi_rule=C:\path\to\rule_for_combinator.rule
:: Required for options 17-20, 22-25
set hashcat_utils_path=C:\path\to\hashcat-utils\binaries
:: Leave set to false, can be toggled with option 26
set enable_username=false
:: Leave set to false, can be toggled with option 27
set enable_output_file=false
:: Output file if enable_output_file is true
set output_file=C:\path\to\output_file.txt
:: Path to attack log file
set log_file=attack_log.txt

:main_menu
echo.
echo ==============================================================
echo              Hashcatalyst v1.0 - by Stealthsploit                  
echo ==============================================================
echo.
echo -----------------------SINGLE ATTACKS-------------------------
echo 1. 8-char ?a incremental brute force (fast hashes only)
echo 2. Hybrid wordlist + 3-char incrementing ?a mask
echo 3. Hybrid all wordlists + 3-char incrementing ?a mask
echo 4. Hybrid 3-char incrementing ?a mask + wordlist
echo 5. Hybrid 3-char incrementing ?a mask + all wordlists
echo 6. Wordlist + rules /w loopback
echo 7. Wordlist + nested rules /w loopback
echo 8. Wordlist + all rules /w loopback
echo 9. All wordlists + rules /w loopback
echo 10. All wordlists + nested rules /w loopback
echo 11. All wordlists + all rules /w loopback
echo 12. Combinator
echo 13. Combinator + rules /w loopback
echo 14. Wordlist + 250,000 random rules /w loopback
echo 15. All wordlists + 250,000 random rules /w loopback
echo.
echo ----------------------ATTACK CHAINING-------------------------
echo 16. Custom attack chain (e.g. 16 to select, then 11,3,5,13,15)
echo.
echo -----------------WORDLIST GENERATION 101+1--------------------
echo 17. Expand wordlist
echo 18. Cutb wordlist
echo 19. Cutb the expanded wordlist        	 (requires 17)
echo 20. Expand the cutb wordlist             (requires 18)
echo 21. Create potfile founds list
echo 22. Expand potfile founds                (requires 21)            
echo 23. Cutb potfile founds                  (requires 21)
echo 24. Expand the cutb potfile founds   	 (requires 21 then 23)
echo 25. Cutb the expanded potfile founds  	 (requires 21 then 22)
echo.
echo ----------------------------MISC------------------------------

if "%enable_username%"=="true" (

    echo 26. Select to DISABLE --username for raw hashlist
) else (
    echo 26. Select to ENABLE --username for user:hash hashlist
)

if "%enable_output_file%"=="true" (
    echo 27. Select to DISABLE output file
) else (
    echo 27. Select to ENABLE output file
)

echo 28. Show current paths
echo 29. Show cracked passwords
echo 30. Exit
echo.
echo Free Password Cracking 101+1 training:
echo https://in.security/technical-training/password-cracking/
echo =============================================================
set /p choice=Select an option (1-30): 

if "%choice%"=="1" goto attack1
if "%choice%"=="2" goto attack2
if "%choice%"=="3" goto attack3
if "%choice%"=="4" goto attack4
if "%choice%"=="5" goto attack5
if "%choice%"=="6" goto attack6
if "%choice%"=="7" goto attack7
if "%choice%"=="8" goto attack8
if "%choice%"=="9" goto attack9
if "%choice%"=="10" goto attack10
if "%choice%"=="11" goto attack11
if "%choice%"=="12" goto attack12
if "%choice%"=="13" goto attack13
if "%choice%"=="14" goto attack14
if "%choice%"=="15" goto attack15
if "%choice%"=="16" goto custom_chain
if "%choice%"=="17" goto expand_wordlist
if "%choice%"=="18" goto cutb_wordlist
if "%choice%"=="19" goto cutb_expand_wordlist
if "%choice%"=="20" goto expand_cutb_wordlist
if "%choice%"=="21" goto create_potfile_list
if "%choice%"=="22" goto expand_potfile_list
if "%choice%"=="23" goto cutb_potfile_list
if "%choice%"=="24" goto expand_cutb_potfile_list
if "%choice%"=="25" goto cutb_expand_potfile_list
if "%choice%"=="26" goto toggle_username
if "%choice%"=="27" goto toggle_output_file
if "%choice%"=="28" goto show_paths
if "%choice%"=="29" goto show_passwords
if "%choice%"=="30" goto exit_to_prompt

echo Invalid selection. Please choose a valid option.
pause
goto main_menu

:toggle_username
if "%enable_username%"=="false" (
    set enable_username=true
    echo --username ENABLED for user:hash hashlist
) else (
    set enable_username=false
    echo --username DISABLED for raw hashlist
)
pause
goto main_menu

:toggle_output_file
if "%enable_output_file%"=="false" (
    set enable_output_file=true
    echo Output file ENABLED: %output_file%
) else (
    set enable_output_file=false
    echo Output file DISABLED
)
pause
goto main_menu

:expand_wordlist
"%hashcat_utils_path%\expander.exe" < "%wordlist%" | rlite.exe stdin -o "%wordlist_dir%\expanded.wordlist.txt"
echo Expanded wordlist created at %wordlist_dir%\expanded.wordlist.txt
pause
goto main_menu

:cutb_wordlist
for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" 0 %%i < "%wordlist%" >> "%wordlist_dir%\cutb.wordlist.forward.tmp"
for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" -%%i < "%wordlist%" >> "%wordlist_dir%\cutb.wordlist.reverse.tmp"
type "%wordlist_dir%\cutb.wordlist.forward.tmp" "%wordlist_dir%\cutb.wordlist.reverse.tmp" | rlite.exe stdin -o "%wordlist_dir%\cutb.wordlist.combined.txt"
rlite.exe "%wordlist_dir%\cutb.wordlist.forward.tmp" -o "%wordlist_dir%\cutb.wordlist.forward"
rlite.exe "%wordlist_dir%\cutb.wordlist.reverse.tmp" -o "%wordlist_dir%\cutb.wordlist.reverse"
del "%wordlist_dir%\cutb.wordlist.forward.tmp" "%wordlist_dir%\cutb.wordlist.reverse.tmp"
echo Cutb combined wordlist created at %wordlist_dir%\cutb.wordlist.combined.txt 
pause
goto main_menu

:cutb_expand_wordlist
if not exist "%wordlist_dir%\expanded.wordlist.txt" (
    echo Error: %wordlist_dir%\expanded.wordlist.txt not found, run option 17 first
    pause
    goto main_menu
)

for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" 0 %%i < "%wordlist_dir%\expanded.wordlist.txt" >> "%wordlist_dir%\cutb.expanded.wordlist.forward.tmp"
for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" -%%i < "%wordlist_dir%\expanded.wordlist.txt" >> "%wordlist_dir%\cutb.expanded.wordlist.reverse.tmp"
type "%wordlist_dir%\cutb.expanded.wordlist.forward.tmp" "%wordlist_dir%\cutb.expanded.wordlist.reverse.tmp" | rlite.exe stdin -o "%wordlist_dir%\cutb.expanded.wordlist.combined.txt"
rlite.exe "%wordlist_dir%\cutb.expanded.wordlist.forward.tmp" -o "%wordlist_dir%\cutb.expanded.wordlist.forward"
rlite.exe "%wordlist_dir%\cutb.expanded.wordlist.reverse.tmp" -o "%wordlist_dir%\cutb.expanded.wordlist.reverse"
del "%wordlist_dir%\cutb.expanded.wordlist.forward.tmp" "%wordlist_dir%\cutb.expanded.wordlist.reverse.tmp"
echo Cutb the expanded wordlist and created at %wordlist_dir%\cutb.expanded.wordlist.combined.txt
pause
goto main_menu

:expand_cutb_wordlist
if not exist "%wordlist_dir%\cutb.wordlist.combined.txt" (
    echo Error: %wordlist_dir%\cutb.wordlist.combined.txt not found, run option 18 first
    pause
    goto main_menu
)

"%hashcat_utils_path%\expander.exe" < "%wordlist_dir%\cutb.wordlist.combined.txt" | rlite.exe stdin -o "%wordlist_dir%\expanded.cutb.wordlist.combined.txt"
echo Expanded the cutb wordlist and created at %wordlist_dir%\expanded.cutb.wordlist.combined.txt
pause
goto main_menu

:potfile_filter
set "pot_cmd=hashcat.exe -m%hashcat_mode% "%hash_list%" --potfile-path="%potfile_path%" --show --outfile-format=2"
if "%enable_username%"=="true" set "pot_cmd=!pot_cmd! --username"
cmd /c "!pot_cmd! > "!founds_file!""
goto :eof

:create_potfile_list
for /f "tokens=* delims=" %%A in ('echo %potfile_path%') do set "potfile_path=%%A"
for %%F in ("%potfile_path%") do set "founds_file=%wordlist_dir%\%%~nF.txt"
if not exist "%potfile_path%" (
    echo Error: "%potfile_path%" not found.
    pause
    goto :eof
)

call :potfile_filter

findstr /C:"Token length exception" "%founds_file%" >nul
if not errorlevel 1 (
    echo Hashfile might contain usernames but --username isn't enabled, run option 26 and try again.
    pause
    goto main_menu
)

findstr /C:"Failed to parse hashes" "%founds_file%" >nul
if not errorlevel 1 (
    echo Hashfile doesn't have users but --username is enabled, run option 26 and try again.
    pause
    goto main_menu
)

echo Potfile wordlist created at "%founds_file%"
pause
goto main_menu

:show_passwords
set "show_pass=hashcat.exe -m%hashcat_mode% "%hash_list%" --potfile-path="%potfile_path%" --show"
if "%enable_username%"=="true" set "show_pass=!show_pass! --username"
cmd /c "!show_pass!"
goto main_menu

:expand_potfile_list
for %%F in ("%potfile_path%") do set "founds_file=%wordlist_dir%\%%~nF.txt"
if not exist "%founds_file%" (
    echo Error: %founds_file% not found, run option 21 first
    pause
    goto main_menu
)

"%hashcat_utils_path%\expander.exe" < "%founds_file%" | rlite.exe stdin -o "%wordlist_dir%\expanded.potfile.txt"
echo Expanded potfile wordlist created at %wordlist_dir%\expanded.potfile.txt
pause
goto main_menu

:cutb_potfile_list
for %%F in ("%potfile_path%") do set "founds_file=%wordlist_dir%\%%~nF.txt"
if not exist "%founds_file%" (
    echo Error: %founds_file% not found, run option 21 first
    pause
    goto main_menu
)

for %%F in ("%wordlist%") do set "single_wordlist_dir=%%~dpF"
for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" 0 %%i < "%founds_file%" >> "%wordlist_dir%\cutb.potfile.forward.tmp"
for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" -%%i < "%founds_file%" >> "%wordlist_dir%\cutb.potfile.reverse.tmp"
type "%wordlist_dir%\cutb.potfile.forward.tmp" "%wordlist_dir%\cutb.potfile.reverse.tmp" | rlite.exe stdin -o "%wordlist_dir%\cutb.potfile.combined.txt"
rlite.exe "%wordlist_dir%\cutb.potfile.forward.tmp" -o "%wordlist_dir%\cutb.potfile.forward"
rlite.exe "%wordlist_dir%\cutb.potfile.reverse.tmp" -o "%wordlist_dir%\cutb.potfile.reverse"
del "%wordlist_dir%\cutb.potfile.forward.tmp" "%wordlist_dir%\cutb.potfile.reverse.tmp"
echo Cutb potfile wordlist created at %wordlist_dir%\cutb.potfile.combined.txt
pause
goto main_menu

:expand_cutb_potfile_list
if not exist "%wordlist_dir%\cutb.potfile.combined.txt" (
    echo Error: %wordlist_dir%\cutb.potfile.combined.txt not found, run option 23 first
    pause
    goto main_menu
)

for %%F in ("%wordlist%") do set "single_wordlist_dir=%%~dpF"
"%hashcat_utils_path%\expander.exe" < "%wordlist_dir%\cutb.potfile.combined.txt" | rlite.exe stdin -o "%wordlist_dir%\expanded.cutb.potfile.combined.txt"
echo Expanded cutb potfile wordlist created at %wordlist_dir%\expanded.cutb.potfile.combined.txt
pause
goto main_menu

:cutb_expand_potfile_list
if not exist "%wordlist_dir%\expanded.potfile.txt" (
    echo Error: %wordlist_dir%\expanded.potfile.txt not found, run option 22 first
    pause
    goto main_menu
)

for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" 0 %%i < "%wordlist_dir%\expanded.potfile.txt" > "%wordlist_dir%\cutb.expanded.potfile.forward.tmp"
for /L %%i in (1,1,10) do "%hashcat_utils_path%\cutb.exe" -%%i < "%wordlist_dir%\expanded.potfile.txt" > "%wordlist_dir%\cutb.expanded.potfile.reverse.tmp"
type "%wordlist_dir%\cutb.expanded.potfile.forward.tmp" "%wordlist_dir%\cutb.expanded.potfile.reverse.tmp" | rlite.exe stdin -o "%wordlist_dir%\cutb.expanded.potfile.combined.txt"
rlite.exe "%wordlist_dir%\cutb.expanded.potfile.forward.tmp" -o "%wordlist_dir%\cutb.expanded.potfile.forward"
rlite.exe "%wordlist_dir%\cutb.expanded.potfile.reverse.tmp" -o "%wordlist_dir%\cutb.expanded.potfile.reverse"
del "%wordlist_dir%\cutb.expanded.potfile.forward.tmp" "%wordlist_dir%\cutb.expanded.potfile.reverse.tmp"
echo Cutb expanded potfile wordlist created at %wordlist_dir%\cutb.expanded.potfile.combined.txt
pause
goto main_menu

:: Any switches added to "hashcat_command" will be used in every attack excluding combinator attacks 12 and 13 (make changes to 12/13 individually)
:build_hashcat_command
set "hashcat_command=hashcat.exe -m%hashcat_mode% %hash_list% %~1 -O --potfile-path=%potfile_path%"
if "%enable_username%"=="true" set "hashcat_command=!hashcat_command! --username"
if "%enable_output_file%"=="true" set "hashcat_command=!hashcat_command! -o %output_file%"
goto :eof

:show_paths
echo hash_list		%hash_list% 
echo haschat_mode		%hashcat_mode%
echo potfile_path		%potfile_path%
echo wordlist		%wordlist%
echo rule_file		%rule_file%
echo rule_folder		%rule_folder%
echo nested_rulefile		%nested_rulefile%
echo wordlist_dir		%wordlist_dir%
echo combi_list1		%combi_list1%
echo combi_list2		%combi_list2%
echo combi_rule		%combi_rule%
echo hashcat_utils_path	%hashcat_utils_path%
pause
goto main_menu

:attack1
echo Running 8-char incremental brute force (8x ?a - fast hashes only)...
call :build_hashcat_command "-a3 ?a?a?a?a?a?a?a?a -i"
(echo. & echo [%date% %time%][Started 8-char incremental brute force] !hashcat_command!) >> %log_file%
!hashcat_command!
goto :eof

:attack2
echo Running Hybrid wordlist + 3-char incrementing ?a mask...
call :build_hashcat_command "-a6 %wordlist% ?a?a?a -i"
(echo. & echo [%date% %time%][Started Hybrid wordlist + 3-char incrementing ?a mask] !hashcat_command!) >> %log_file%
!hashcat_command!
goto :eof

:attack3
echo Running Hybrid all wordlists + 3-char incrementing ?a mask...
for %%w in (%wordlist_dir%\*.txt) do (
	set "timestamp=!date! !time!"
    call :build_hashcat_command "-a6 %%w ?a?a?a -i"
	(echo. & echo [!timestamp!][Started Hybrid all wordlists + 3-char incrementing ?a mask] !hashcat_command!) >> %log_file%
    !hashcat_command!
)
goto :eof

:attack4
echo Running Hybrid 3-char incrementing ?a mask + wordlist...
call :build_hashcat_command "-a7 ?a?a?a %wordlist% -i"
(echo. & echo [%date% %time%][Started Hybrid 3-char incrementing ?a mask + wordlist] !hashcat_command!) >> %log_file%
!hashcat_command!
goto :eof

:attack5
echo Running Hybrid 3-char incrementing ?a mask + all wordlists...
for %%w in (%wordlist_dir%\*.txt) do (
	set "timestamp=!date! !time!"
    call :build_hashcat_command "-a7 ?a?a?a %%w -i"
	(echo. & echo [!timestamp!][Started Hybrid 3-char incrementing ?a mask + all wordlists] !hashcat_command!) >> %log_file%
    !hashcat_command!
)
goto :eof

:attack6
echo Running Wordlist + rules /w loopback...
call :build_hashcat_command "%wordlist% -r %rule_file% --loopback"
(echo. & echo [%date% %time%][Started Wordlist + rules /w loopback] !hashcat_command!) >> %log_file%
!hashcat_command!
goto :eof

:attack7
echo Running Wordlist + nested rules /w loopback...
call :build_hashcat_command "%wordlist% -r %rule_file% -r %nested_rulefile% --loopback"
(echo. & echo [%date% %time%][Started Wordlist + nested rules /w loopback] !hashcat_command!) >> %log_file%
!hashcat_command!
goto :eof

:attack8
echo Running Wordlist + all rules within folder /w loopback
for %%r in (%rule_folder%\*.rule) do (
	set "timestamp=!date! !time!"
	call :build_hashcat_command "%wordlist% -r %%r --loopback"
	(echo. & echo [!timestamp!][Running Wordlist + all rules within folder /w loopback] !hashcat_command!) >> %log_file%
    !hashcat_command!	
)
goto :eof

:attack9
echo Running all wordlists in directory + rule /w loopback...
for %%w in (%wordlist_dir%\*.txt) do (
	set "timestamp=!date! !time!"
    call :build_hashcat_command "%%w -r %rule_file% --loopback"
	(echo. & echo [!timestamp!][Started All wordlists + rule /w loopback] !hashcat_command!) >> %log_file%
    !hashcat_command!
)
goto :eof

:attack10
echo All wordlists + nested rules /w loopback
for %%w in (%wordlist_dir%\*.txt) do (
	set "timestamp=!date! !time!"
	call :build_hashcat_command "%%w -r %rule_file% -r %nested_rulefile% --loopback"
	(echo. & echo [!timestamp!][Started Wordlist + nested rules /w loopback] !hashcat_command!) >> %log_file%
	!hashcat_command!
)
goto :eof

:attack11
echo Running all wordlists in directory + all rules within folder /w loopback...
for %%w in (%wordlist_dir%\*.txt) do (
	for %%r in (%rule_folder%\*.rule) do (
		set "timestamp=!date! !time!"
		call :build_hashcat_command "%%w -r %%r --loopback"
		(echo. & echo [!timestamp!][Started All wordlists + all rules within folder /w loopback] !hashcat_command!) >> %log_file%
		!hashcat_command!
	)
)
goto :eof

:attack12
echo echo Running Combinator attack...
set "combinator_command=hashcat.exe -m%hashcat_mode% %hash_list% --potfile-path=%potfile_path% -O -w3 -a1 %combi_list1% %combi_list2%
if "%enable_username%"=="true" set "combinator_command=%combinator_command% --username"
if "%enable_output_file%"=="true" set "combinator_command=%combinator_command% -o %output_file%"
(echo. & echo [%date% %time%][Started Combinator] !combinator_command!) >> %log_file%
cmd /c %combinator_command%
goto :eof

:attack13
echo Running Combinator + rules attack...
set "combinator_command=hashcat.exe -a1 %combi_list1% %combi_list2% --stdout | hashcat.exe -m%hashcat_mode% %hash_list% -r %combi_rule% -O -w3 --loopback --potfile-path=%potfile_path%"
if "%enable_username%"=="true" set "combinator_command=%combinator_command% --username"
if "%enable_output_file%"=="true" set "combinator_command=%combinator_command% -o %output_file%"
(echo. & echo [%date% %time%][Started Combinator + rules] !combinator_command!) >> %log_file%
cmd /c %combinator_command%
goto :eof

:attack14
echo  Wordlist + 250,000 random rules /w loopback...
call :build_hashcat_command "%wordlist% -g 250000 --loopback"
(echo. & echo [%date% %time%][Started Wordlist + 250,000 rules /w loopback] !hashcat_command!) >> %log_file%
!hashcat_command!
goto :eof

:attack15
echo Running All wordlists + 250,000 random rules /w loopback...
for %%w in (%wordlist_dir%\*.txt) do (
	set "timestamp=!date! !time!"
    call :build_hashcat_command "%%w -g 250000 --loopback"
	(echo. & echo [!timestamp!][Started All wordlists + 250,000 random rules /w loopback] !hashcat_command!) >> %log_file%
    !hashcat_command!
)
goto :eof

:custom_chain
set /p chain_input=Enter custom attack chain (e.g. 16 to select, then 11,3,5,13,15): 
for %%a in (%chain_input%) do (
    echo Running attack %%a...
    call :attack%%a
)
goto main_menu

:exit_to_prompt
cmd /k