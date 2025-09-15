#!/bin/bash

# Hashcatalyst v1.0 by Will Hunt @Stealthsploit
# https://in.security/
# In.security Discord https://discord.gg/5VpwE9YJ9R

# Ensure file paths are set
# Hash list
hash_list="/path/to/hashlist.txt"
# Hashcat algorithm mode, e.g. 0 for MD5
hashcat_mode=0
# Potfile to store cracked hashes
potfile_path="/path/to/hashcat.potfile"
# Single wordlist for use in attacks 2,4,6,7,8,14
wordlist="/path/to/primary_wordlist.txt"
# Rule file for attacks 6,9 and primary rule file for attack 7,10
rule_file="/path/to/primary_rule.rule"
# All *.rule files here used in attacks 8,11
rule_folder="/path/to/rules_folder"
# Nested rule file in attacks 7,10
nested_rulefile="/path/to/nested_rule.rule"
# All *.txt files here used in attacks 3,5,9,10,11,15
wordlist_dir="/path/to/multiple_wordlists"
# First list for combinator in attacks 12,13
combi_list1="/path/to/combilist1.txt"
# Second list for combinator in attacks 12,13
combi_list2="/path/to/combilist2.txt"
# Rule file for use in attack 13
combi_rule="/path/to/rule_for_combinator.rule"
# Required for options 17-20, 22-25
hashcat_utils_path="/path/to/hashcat-utils/binaries"
# Leave set to false, can be toggled with option 26
enable_username=false
# Leave set to false, can be toggled with option 27
enable_output_file=false
# Output file if enable_output_file is true
output_file="/path/to/output_file.txt"
# Path to attack log file
log_file="attack_log.txt"

main_menu() {
    echo "=============================================================="
    echo "              Hashcatalyst v1.0 - @Stealthsploit               "
    echo "=============================================================="
    echo ""
	echo "-----------------------SINGLE ATTACKS-------------------------"
	echo "1. 8-char ?a incremental brute force (fast hashes only)"
    echo "2. Hybrid wordlist + 3-char incrementing ?a mask"
    echo "3. Hybrid all wordlists + 3-char incrementing ?a mask"
    echo "4. Hybrid 3-char incrementing ?a mask + wordlist"
    echo "5. Hybrid 3-char incrementing ?a mask + all wordlists"
    echo "6. Wordlist + rules /w loopback"
    echo "7. Wordlist + nested rules /w loopback"
    echo "8. Wordlist + all rules within folder /w loopback"
    echo "9. All wordlists + rule /w loopback"
	echo "10. All wordlists + nested rules /w loopback"
	echo "11. All wordlists + all rules within folder /w loopback"
	echo "12. Combinator"
    echo "13. Combinator + rules"
	echo "14. Wordlist + 250,000 random rules /w loopback"
	echo "15. All wordlists + 250,000 random rules /w loopback"
	echo ""
	echo "----------------------ATTACK CHAINING-------------------------"
    echo "16. Custom attack chain (e.g. 16 to select, then 11,3,5,13,15)"
	echo ""
	echo "-----------------WORDLIST GENERATION 101+1--------------------"
	echo "17. Expand wordlist"
	echo "18. Cutb wordlist"
	echo "19. Cutb the expanded wordlist        	 (requires 17)"
	echo "20. Expand the cutb wordlist             (requires 18)"
	echo "21. Create potfile founds list"
	echo "22. Expand potfile founds                (requires 21)"            
	echo "23. Cutb potfile founds                  (requires 21)"
	echo "24. Expand the cutb potfile founds   	 (requires 20 then 22)"
	echo "25. Cutb the expanded potfile founds  	 (requires 20 then 21)"
	echo ""
	echo "----------------------------MISC------------------------------"
	
    if [ "$enable_username" = true ]; then
        echo "26. Select to DISABLE --username for raw hashlist"
    else
        echo "26. Select to ENABLE --username for user:hash hashlist"
    fi
    
	if [ "$enable_output_file" = true ]; then
        echo "27. Select to DISABLE output file"
    else
        echo "27. Select to ENABLE output file"
    fi
    
	echo "28. Show current paths"
	echo "29. Show cracked passwords"
	echo "30. Exit"
    echo ""
	echo "Free Password Cracking 101+1 training:"
    echo "https://in.security/technical-training/password-cracking/"
	echo "=============================================================="
    read -p "Select an option (1-30): " choice
    case $choice in
        1) attack1 ;;
        2) attack2 ;;
        3) attack3 ;;
        4) attack4 ;;
        5) attack5 ;;
        6) attack6 ;;
        7) attack7 ;;
        8) attack8 ;;
        9) attack9 ;;
        10) attack10 ;;
		11) attack11 ;;
		12) attack12 ;;
		13) attack13 ;;
		14) attack14 ;;
		15) attack15 ;;
        16) custom_chain ;;
		17) expand_wordlist ;;
		18) cutb_wordlist ;;
		19) cutb_expand_wordlist ;;
		20) expand_cutb_wordlist ;;
		21) create_potfile_list ;;
		22) expand_potfile_list ;;
		23) cutb_potfile_list ;;
		24) expand_cutb_potfile_list ;;
		25) cutb_expand_potfile_list ;;
        26) toggle_username ;;
        27) toggle_output_file ;;
		28) show_paths ;;
		29) show_passwords ;;
        30) exit 0 ;;
        *) echo "Invalid selection. Please choose a valid option."; sleep 1; main_menu ;;
    esac
}

toggle_username() {
    enable_username=$([ "$enable_username" = true ] && echo false || echo true)
    main_menu
}

toggle_output_file() {
    enable_output_file=$([ "$enable_output_file" = true ] && echo false || echo true)
    main_menu
}

expand_wordlist() {
	"$hashcat_utils_path/expander.bin" < "$wordlist" | ./rlite.bin stdin -o "$wordlist_dir/expanded.wordlist.txt"
	echo Expanded wordlist created at $wordlist_dir/expanded.wordlist.txt
	main_menu
}

cutb_wordlist() {
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" 0 "$i" < "$wordlist" >> "$wordlist_dir/cutb.wordlist.forward.txt.tmp" ;done
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" -"$i" < "$wordlist" >> "$wordlist_dir/cutb.wordlist.reverse.txt.tmp" ;done
	cat "$wordlist_dir/cutb.wordlist.forward.txt.tmp" "$wordlist_dir/cutb.wordlist.reverse.txt.tmp" | ./rlite.bin stdin -o "$wordlist_dir/cutb.wordlist.combined.txt"
	./rlite.bin "$wordlist_dir/cutb.wordlist.forward.txt.tmp" -o "$wordlist_dir/cutb.wordlist.forward"
	./rlite.bin "$wordlist_dir/cutb.wordlist.reverse.txt.tmp" -o "$wordlist_dir/cutb.wordlist.reverse"
	rm "$wordlist_dir/cutb.wordlist.forward.txt.tmp" "$wordlist_dir/cutb.wordlist.reverse.txt.tmp"
	echo Cutb combined wordlist created at $wordlist_dir/cutb.wordlist.combined.txt
	main_menu
}

cutb_expand_wordlist() {
	if [[ ! -f "$wordlist_dir/expanded.wordlist.txt" ]]; then
        echo Error: $wordlist_dir/expanded.wordlist.txt not found, run option 17 first
        sleep 2
        main_menu
        return
    fi
	
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" 0 "$i" < "$wordlist_dir/expanded.wordlist.txt" >> "$wordlist_dir/cutb.expanded.wordlist.forward.txt.tmp" ;done
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" -"$i" < "$wordlist_dir/expanded.wordlist.txt" >> "$wordlist_dir/cutb.expanded.wordlist.reverse.txt.tmp" ;done
	cat "$wordlist_dir/cutb.expanded.wordlist.forward.txt.tmp" "$wordlist_dir/cutb.expanded.wordlist.reverse.txt.tmp" | ./rlite.bin stdin -o "$wordlist_dir/cutb.expanded.wordlist.combined.txt"
	./rlite.bin "$wordlist_dir/cutb.expanded.wordlist.forward.txt.tmp" -o "$wordlist_dir/cutb.expanded.wordlist.forward"
	./rlite.bin "$wordlist_dir/cutb.expanded.wordlist.reverse.txt.tmp" -o "$wordlist_dir/cutb.expanded.wordlist.reverse"
	rm "$wordlist_dir/cutb.expanded.wordlist.forward.txt.tmp" "$wordlist_dir/cutb.expanded.wordlist.reverse.txt.tmp"
	echo Cutb the expanded wordlist and created at $wordlist_dir/cutb.expanded.wordlist.combined.txt
	main_menu
}

expand_cutb_wordlist() {
	if [[ ! -f "$wordlist_dir/cutb.wordlist.combined.txt" ]]; then
        echo Error: $wordlist_dir/cutb.wordlist.combined.txt not found, run option 18 first
        sleep 2
        main_menu
        return
    fi
	
	"$hashcat_utils_path/expander.bin" < "$wordlist_dir/cutb.wordlist.combined.txt" | ./rlite.bin stdin -o "$wordlist_dir/expanded.cutb.wordlist.combined.txt"
	echo Expanded the cutb wordlist and created at $wordlist_dir/expanded.cutb.wordlist.combined.txt
	main_menu
}

potfile_filter() {
    pot_cmd="./hashcat -m$hashcat_mode $hash_list --potfile-path=$potfile_path --show --outfile-format=2"
    [ "$enable_username" = true ] && pot_cmd+=" --username"
    $pot_cmd > "$founds_file"
}

create_potfile_list() {
	if [[ ! -f "$potfile_path" ]]; then
        echo Error: $potfile_path not found.
        sleep 2
        main_menu
        return
    fi
	
	founds_file="$wordlist_dir/$(basename "$potfile_path" .pot).txt"
	potfile_filter
	
	if grep -q "Token length exception" "$founds_file"; then
        echo "Hashfile might contain usernames but --username isn't enabled, run option 26 and try again."
        sleep 2
        main_menu
        return
    fi

    if grep -q "Failed to parse hashes" "$founds_file"; then
        echo "Hashfile doesn't have users but --username is enabled, run option 26 and try again."
        sleep 2
        main_menu
        return
    fi
	
	echo Potfile wordlist created at "$founds_file"
	main_menu
}

show_passwords() {
    show_pass="./hashcat -m$hashcat_mode $hash_list --potfile-path=$potfile_path --show"
    [ "$enable_username" = true ] && show_pass+=" --username"
    $show_pass
	
main_menu
}

expand_potfile_list() {
	founds_file="$wordlist_dir/$(basename "$potfile_path" .pot).txt"
	if [[ ! -f "$founds_file" ]]; then
		echo Error: "$founds_file" not found, run option 21 first
		sleep 2
		main_menu
		return
    fi
	
	"$hashcat_utils_path/expander.bin" < "$founds_file" | ./rlite.bin stdin -o "$wordlist_dir/expanded.potfile.txt"
	echo Expanded potfile wordlist created at $wordlist_dir/expanded.potfile.txt
	main_menu
}

cutb_potfile_list() {
	founds_file="$wordlist_dir/$(basename "$potfile_path" .pot).txt"
	if [[ ! -f "$founds_file" ]]; then
		echo Error: "$founds_file" not found, run option 21 first
		sleep 2
		main_menu
		return
    fi
	
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" 0 "$i" < "$founds_file" >> "$wordlist_dir/cutb.potfile.forward.txt.tmp" ;done
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" -"$i" < "$founds_file" >> "$wordlist_dir/cutb.potfile.reverse.txt.tmp" ;done
	cat "$wordlist_dir/cutb.potfile.forward.txt.tmp" "$wordlist_dir/cutb.potfile.reverse.txt.tmp" | ./rlite.bin stdin -o "$wordlist_dir/cutb.potfile.combined.txt"
	./rlite.bin "$wordlist_dir/cutb.potfile.forward.txt.tmp" -o "$wordlist_dir/cutb.potfile.forward"
	./rlite.bin "$wordlist_dir/cutb.potfile.reverse.txt.tmp" -o "$wordlist_dir/cutb.potfile.reverse"
	rm "$wordlist_dir/cutb.potfile.forward.txt.tmp" "$wordlist_dir/cutb.potfile.reverse.txt.tmp"
	echo Cutb potfile combined list created at $wordlist_dir/cutb.potfile.combined.txt
	main_menu
}

expand_cutb_potfile_list() {
	if [[ ! -f "$wordlist_dir/cutb.potfile.combined.txt" ]]; then
		echo Error: $wordlist_dir/cutb.potfile.combined.txt not found, run option 23 first
		sleep 2
		main_menu
		return
    fi
	
	"$hashcat_utils_path/expander.bin" < "$wordlist_dir/cutb.potfile.combined.txt" | ./rlite.bin stdin -o "$wordlist_dir/expanded.cutb.potfile.combined.txt"
	echo Expanded cutb potfile wordlist and created at $wordlist_dir/expanded.cutb.potfile.combined.txt
	main_menu
}

cutb_expand_potfile_list() {
	if [[ ! -f "$wordlist_dir/expanded.potfile.txt" ]]; then
		echo Error: $wordlist_dir/expanded.potfile.txt not found, run option 22 first
		sleep 2
		main_menu
		return
    fi
	
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" 0 "$i" < "$wordlist_dir/expanded.potfile.txt" >> "$wordlist_dir/cutb.expanded.potfile.forward.txt.tmp" ;done
	for i in {0..10}; do "$hashcat_utils_path/cutb.bin" -"$i" < "$wordlist_dir/expanded.potfile.txt" >> "$wordlist_dir/cutb.expanded.potfile.reverse.txt.tmp" ;done
	cat "$wordlist_dir/cutb.expanded.potfile.forward.txt.tmp" "$wordlist_dir/cutb.expanded.potfile.reverse.txt.tmp" | ./rlite.bin stdin -o "$wordlist_dir/cutb.expanded.potfile.combined.txt"
	./rlite.bin "$wordlist_dir/cutb.expanded.potfile.forward.txt.tmp" -o "$wordlist_dir/cutb.expanded.potfile.forward"
	./rlite.bin "$wordlist_dir/cutb.expanded.potfile.reverse.txt.tmp" -o "$wordlist_dir/cutb.expanded.potfile.reverse"
	rm "$wordlist_dir/cutb.expanded.potfile.forward.txt.tmp" "$wordlist_dir/cutb.expanded.potfile.reverse.txt.tmp"
	echo Cutb expanded potfile wordlist and created at $wordlist_dir/cutb.expanded.potfile.combined.txt
	main_menu
}

# Any switches added to "hashcat_command" will be used in every attack excluding combinator attacks 12 and 13 (make changes to 12/13 individually)
build_hashcat_command() {
    hashcat_command="./hashcat -m$hashcat_mode $hash_list $1 -O --potfile-path=$potfile_path"
    [ "$enable_username" = true ] && hashcat_command+=" --username"
    [ "$enable_output_file" = true ] && hashcat_command+=" -o $output_file"
}

show_paths() {
	echo -e hash_list '\t' '\t' $hash_list 
	echo -e haschat_mode '\t' '\t' $hashcat_mode
	echo -e potfile_path '\t' '\t' $potfile_path
	echo -e wordlist '\t' '\t' $wordlist
	echo -e rule_file '\t' '\t' $rule_file
	echo -e rule_folder '\t' '\t' $rule_folder
	echo -e nested_rulefile '\t' $nested_rulefile
	echo -e wordlist_dir '\t' '\t' $wordlist_dir
	echo -e combi_list1 '\t' '\t' $combi_list1
	echo -e combi_list2 '\t' '\t' $combi_list2
	echo -e combi_rule '\t' '\t' $combi_rule
	echo -e hashcat_utils_path '\t' $hashcat_utils_path
	echo ""
	read -p "Press any key to return..." -n1 -s
	main_menu
}

logging() {
    echo -e "\n[$(date)][Started $1] $2" >> "$log_file"
    eval "$2"
}

attack1() {
    build_hashcat_command "-a3 ?a?a?a?a?a?a?a?a -i"
    logging "8-char incremental brute force" "$hashcat_command"
}

attack2() {
    build_hashcat_command "-a6 $wordlist ?a?a?a -i"
    logging "Hybrid wordlist + 3-char incrementing ?a mask" "$hashcat_command"
}

attack3() {
    for w in "$wordlist_dir"/*.txt; do
		build_hashcat_command "-a6 $w ?a?a?a -i"
		logging "Hybrid all wordlists + 3-char incrementing ?a mask" "$hashcat_command"
    done
}

attack4() {
    build_hashcat_command "-a7 ?a?a?a $wordlist -i"
    logging "Hybrid 3-char incrementing ?a mask + wordlist" "$hashcat_command"
}

attack5() {
    for w in "$wordlist_dir"/*.txt; do
		build_hashcat_command "-a7 ?a?a?a $w -i"
		logging "Hybrid 3-char incrementing ?a mask + all wordlists" "$hashcat_command"
    done
}

attack6() {
    build_hashcat_command "$wordlist -r $rule_file --loopback"
    logging "Wordlist + rules /w loopback" "$hashcat_command"
}

attack7() {
    build_hashcat_command "$wordlist -r $rule_file -r $nested_rulefile --loopback"
    logging "Wordlist + nested rules /w loopback" "$hashcat_command"
}

attack8() {
    for r in "$rule_folder"/*.rule; do
		build_hashcat_command "$wordlist -r $r --loopback"
		logging "Wordlist + all rules within folder /w loopback" "$hashcat_command"
    done
}

attack9() {
    for w in "$wordlist_dir"/*.txt; do
		build_hashcat_command "$w -r $rule_file --loopback"
		logging "All wordlists + rule /w loopback" "$hashcat_command"
    done
}

attack10() {
    for w in "$wordlist_dir"/*.txt; do
		build_hashcat_command "$w -r $rule_file -r $nested_rulefile --loopback"
		logging "All wordlists + nested rules /w loopback" "$hashcat_command"
    done
}

attack11() {
    for w in "$wordlist_dir"/*.txt; do
		for r in "$rule_folder"/*.rule; do
			build_hashcat_command "$w -r $r --loopback"
			logging "All wordlists + all rules within folder /w loopback" "$hashcat_command"
		done
	done
}

attack12() {
    combinator_command="./hashcat -m$hashcat_mode $hash_list -O -w3 --potfile-path=$potfile_path -a1 $combi_list1 $combi_list2"
	[ "$enable_username" = true ] && combinator_command+=" --username"
    [ "$enable_output_file" = true ] && combinator_command+=" -o $output_file"
    logging "Combinator" "$combinator_command"
}

attack13() {
    combinator_command="./hashcat -a1 $combi_list1 $combi_list2 --stdout | ./hashcat -m$hashcat_mode $hash_list -r $combi_rule -O -w3 --loopback --potfile-path=$potfile_path"
	[ "$enable_username" = true ] && combinator_command+=" --username"
    [ "$enable_output_file" = true ] && combinator_command+=" -o $output_file"
    logging "Combinator" "$combinator_command"
}

attack14() {
	build_hashcat_command "$wordlist -g 250000 --loopback"
    logging "Wordlist + 250,000 random rules" "$hashcat_command"
}

attack15() {
	for w in "$wordlist_dir"/*.txt; do
		build_hashcat_command "$w -g 250000 --loopback"
		logging "All wordlists + 250,000 random rules /w loopback" "$hashcat_command"
    done
}

custom_chain() {
    read -p "Enter custom attack chain (e.g. 16 to select, then 11,3,5,13,15): " chain_input
    IFS=',' read -ra attacks <<< "$chain_input"
    for attack in "${attacks[@]}"; do
        echo "Running attack $attack..."
        attack"$attack"
    done
    main_menu
}

main_menu
