# Hashcatalyst
Hashcatalyst is a wrapper for hashcat and is designed to automate traditional password cracking attacks, chaining them together to minimise wasted time in between sessions. There’s Windows batch file and Linux bash script variants and it features:

- Flexible attack chaining for brute force, multi-wordlist + (nested) rule, hybrid, combinator and random rule generation attacks
- Enhanced wordlist generation
- Hashcat command logging

<br>
<h2>Setup</h2>

**Important:** 
- Hashcatalyst needs to run from your hashcat folder. It calls **hashcat.exe** and **./hashcat** directly (If you're calling **hashcat.bin** in Linux, modify _hashcat_command_ within the _build_hashcat_command_ section of the respective script).
- It expects your hash(es) to be in a file. If you want to pass a single hash via stdin, replace _%hash_list%_ (Windows) or _$hash_list_ (Linux) in the _build_hashcat_command_ section with your hash.
- The included Windows/Linux [rlite binary](https://github.com/Cynosureprime/rlite) needs to be in the same folder that Hashcatalyst is run from.
- At the top of the script(s), set your file paths for your hash list, mode, potfile, list/rule and folder locations, and optionally the hashcat utils path if you want to use the enhanced wordlist generation options (requires expander and cutb to be compiled in the target folder). A windows example is shown below.
- Ensure all wordlists in the _wordlist_dir_ path have a **.txt** extension and rules in the _rule_folder_ path have a **.rule** extension.

```
set hash_list=C: \hashcat-6.2.6\MD5hashes.txt
set hashcat_mode=0
set potfile_path=C:\hashcat-6.2.6\hashcat.potfile
set wordlist=C:\wordlists\Hashcatalyst\google-10000-english.txt
set rule_file=C:\hashcat-6.2.6\rules\Hashcatalyst\OneRuleToRuleThemStill.rule
set rule_folder=C:\hashcat-6.2.6\rules\Hashcatalyst
set nested_rulefile=C:\hashcat-6.2.6\rules\Hashcatalyst\best64.rule
set wordlist_dir=C:\wordlists\Hashcatalyst
set combi_list1=C:\wordlists\Hashcatalyst\combi1.txt
set combi_list2=C:\wordlists\Hashcatalyst\combi2.txt
set combi_rule=C:\hashcat-6.2.6\rules\Hashcatalyst\OneRuleToRuleThemStill.rule
set hashcat_utils_path=C:\hashcat-6.2.6\hashcat-utils\src
set enable_username=false
set enable_output_file=false
set output_file=C:\hashcat-6.2.6\output.txt
set log_file=C:\Data\Tools\hashcat-6.2.6\attack_log.txt
```

<br>
<h2>Usage</h2>

After setting up your file/folder paths above, simply run **Hashcatalyst.bat** from a Windows cmd prompt (not PowerShell), or **./Hashcatalyst.sh** for Linux.

```
==============================================================
             Hashcatalyst v1.0 - by Stealthsploit
==============================================================

-----------------------SINGLE ATTACKS-------------------------
1. 8-char ?a incremental brute force (fast hashes only)
2. Hybrid wordlist + 3-char incrementing ?a mask
3. Hybrid all wordlists + 3-char incrementing ?a mask
4. Hybrid 3-char incrementing ?a mask + wordlist
5. Hybrid 3-char incrementing ?a mask + all wordlists
6. Wordlist + rules /w loopback
7. Wordlist + nested rules /w loopback
8. Wordlist + all rules /w loopback
9. All wordlists + rules /w loopback
10. All wordlists + nested rules /w loopback
11. All wordlists + all rules /w loopback
12. Combinator
13. Combinator + rules /w loopback
14. Wordlist + 250,000 random rules /w loopback
15. All wordlists + 250,000 random rules /w loopback

----------------------ATTACK CHAINING-------------------------
16. Custom attack chain (e.g. 16 to select, then 11,3,5,13,15)

-----------------WORDLIST GENERATION 101+1--------------------
17. Expand wordlist
18. Cutb wordlist
19. Cutb the expanded wordlist           (requires 17)
20. Expand the cutb wordlist             (requires 18)
21. Create potfile founds list
22. Expand potfile founds                (requires 21)
23. Cutb potfile founds                  (requires 21)
24. Expand the cutb potfile founds       (requires 21 then 23)
25. Cutb the expanded potfile founds     (requires 21 then 22)

----------------------------MISC------------------------------
26. Select to ENABLE --username for user:hash hashlist
27. Select to ENABLE output file
28. Show current paths
29. Exit

Free Password Cracking 101+1 training:
https://in.security/technical-training/password-cracking/
=============================================================
Select an option (1-29):
```

<br>
<h2>Single Attacks</h2>

For a single attack, simply type the menu number to execute the associated attack. Assuming your file/folder paths exist and contain the required lists/rules, hashcat will perform the attack. For explanations of these attacks, check out our [password cracking blogs](https://in.security/category/passwords/) and further detail (amongst many more attacks not included in Hashcatalyst) in our [free Password Cracking 101+1 training](https://in.security/technical-training/password-cracking/). You’ve also got the [hashcat wiki](https://hashcat.net/wiki/) of course.

<br>
<h2>Attack Chaining</h2>

If you’re using Hashcatalyst, chances are it’s because you want to execute multiple attacks in succession with no downtime. Select option 16 (custom attack chain).

After selecting it, enter comma separated menu options for the attacks you want. 
- E.g. if you want a hybrid wordlist + mask attack (attack 2), then a wordlist attack with every rule in your specified rule folder (menu 8), followed by a combinator attack + rules (menu 13), select option **16**, and then enter **2,8,13**

<br>
<h2>Wordlist Generation 101+1</h2>

Wordlists are great, but when you’ve exhausted your usual lists, augmenting them can help generate new candidates.

Nearly all options require the _expander_ and _cutb_ utilities from [hashcat-utils](https://github.com/hashcat/hashcat-utils) to be compiled in the specified _hashcat_utils_path_ path. Hashcatalyst will look for _expander.exe_ / _cutb.exe_, or _expander.bin_ / _cutb.bin_ respectively. Details on what these utilities do can be found in the [hashcat wiki](https://hashcat.net/wiki/doku.php?id=hashcat_utils). All augmented wordlists created from the below options will be stored in the specified _wordlist_dir_ path. The Windows/Linux [rlite binaries](https://github.com/Cynosureprime/rlite) are used for deduping as they're very efficient and fast compared to `sort -u` (and although Windows sort.exe has an undocumented /unique switch, it's fairly useless and doesn't handle non-ASCII well).

- Options 17 and 18 will expand or cutb your specified wordlist
- Option 19 takes your expanded wordlist from option 17 and runs cutb over it
- Option 20 takes your cutb wordlist from option 17 and runs expander over it
- Option 21 extracts the plain text founds from your potfile and stores them as a new wordlist
- Option 22 expands your potfile wordlist created in option 21
- Option 23 runs cutb on your potfile wordlist created in option 21
- Option 24 expands your cutb potfile list from option 23
- Option 25 runs cutb over your expanded potfile list from option 22

Cutb will cut from 0 through 10, forward and reverse, then merges and dedupes with rlite before creating a final combined list. Expander wordlists are also deduped.

<br>
<h2>Misc</h2>

Option 26 toggles hashcat’s _--username_ switch. If your hash list is _user:hash_ formatted then this needs to be enabled before cracking. Option 27 enables an output file specified in _output_file_ to store your cracks. Hashcatalyst will still store cracks in your specified potfile by default whether you’ve enabled an output file or not.

Option 28 will print out the current file/folder variables you’ve set for ease of viewing.

Option 29 will show you cracked hashes from your potfile. If your hash list contains usernames, don't forget to toggle _--username_ with option 26 first.

<br>
<h2>Logging</h2>

Hashcatalyst automatically appends to a log file wherever specified in the _log_file_ path (defaults to _attack_log.txt_ in the current folder). Each attack in your chain will be timestamped when it begins so you can see how long each attack is taking and to keep track what you’ve completed. This is also useful for debugging failed hashcat sessions if an attack that should take hours finishes in minutes. 

Please note, the log is appended the second hashcat is invoked. If it takes time to load dictionaries/rules that subsequently fail, the attack will still be logged.

<br>
<h2>Notes/Tips</h2>

- Unless you’re attacking a fast hash and fairly confident that the 8-char brute force (attack 1) will exhaust for your given hardware in a satisfactory time, skip it and focus on the other attacks.
- By default, expander has a LEN_MAX of 4. I prefer to recompile with 8 for better milage, but it’s personal preference.
- Hashcatalyst uses optimised kernels (-O) in all attacks as hashcat will automatically fall back to a pure kernel where an optimised one isn’t available.
- Hashcatalyst is a simple wrapper and doesn’t add any functionality to hashcat. If you’re getting _hashcat_ errors then there’s something wrong in the attack you’re trying to perform and you’ll need to debug using hashcat!

<br>
<h2>FAQ</h2>

Should I run a custom chain and enter 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ?
- Generally, no. There’s many reasons why that’s not worth it. An 8-char brute force (option 1) might not even finish depending on the algorithm/your hardware, and some of the other options could overlap depending on the lists/rules you target, meaning lots of duplicated/redundant guesses and compute that would be wasted.

  Assuming a fast hash, list/rule and hybrid attacks aren’t a bad start, so as an example you could try 8,2,4,14 and build up from there depending on your needs. This will ultimately come down to person preference.

I thought combinator mode -a1 only allows for single rules -j and -k against the left/right wordlist, but attack 13 is using a full ruleset?
- Indeed it is! To increase the chances of successful cracks, Hashcatalyst is piping hashcat into itself to work around this. For an MD5 example, it’s executing _hashcat -a1 combi_list1 combi_list2 --stdout | hashcat -m0 MD5hashes.txt -r OneRuleToRuleThemStill.rule -O_

Which wordlists and rules should I use?
- It’s not easy to answer because depending on the hash algorithm, available hardware and the attacks you choose, you could finish multiple attacks in a few hours, or you might not finish an 8-char brute force by itself. Start with your usual lists/rules use and add to/reduce them if needed. Check out my [OneRuleToRuleThemStill.rule](https://github.com/stealthsploit/OneRuleToRuleThemStill) which is good start for fast hashes.

What happens if hashcat errors for some reason halfway through a custom attack chain?
- Hashcat generally tries to tell you what an error means but Hashcatalyst will likely skip the error too quicky and carry on to the next attack. You therefore may need to manually (not using Hashcatalyst) try a failing attack to debug. Hashcatalyst logs timestamped attacks as they start, so if you notice that a big wordlist/rule set seemingly took 20 seconds to complete before moving on, it’s likely that hashcat couldn’t start the attack for some reason or because you gave it an infeasible/incalculable attack.  Hashcatalyst is only a wrapper around hashcat, nothing more!

Are there any configurations I should avoid?
- For nested rule attacks, don’t choose two large rulesets. E.g. if your primary rule is OneRuleToRuleThemStill.rule, don’t nest that with itself/bigger rules as it’ll likely error out. One of the two rule files should be much smaller. It may be worth manually testing _-r rule1.rule -r rule2.rule_ in hashcat beforehand just to ensure your system can handle it. For example, the [hob064 rule](https://github.com/praetorian-inc/Hob0Rules/blob/master/hob064.rule) is a small and efficient rule for nesting to get you started.

What is loopback?
- A fantastic feature for rule-based attacks. After a session exhausts, it’ll feed cracked passwords back in, re-mangling a second time to see if any more crack. It’ll keep going until there’s no more cracks.

Ultimately you can modify Hashcatalyst to tweak the attacks to your choosing, or even create multiple Hashcatalyts’ per algorithm so that you have preset lists/rules for fast and slow hashes.

<br>
<h2>Future Plans</h2>
I don't have any immediate plans to develop the public version of Hashcatalyst further. The attack modules can be modified to inlcude other hashcat commands you might want for your methodologies, so feel free to adapt it.
<br>
<br>
The code will be suboptimal (I don't have a development background!). This was put together to be flexible and extensible, nothing more.

Happy cracking!

<br>
<h2>Shout Outs</h2>

A special thanks to [tychotithonus](https://github.com/roycewilliams) and [Chick3nman](https://github.com/Chick3nman) for reviewing and feedback.
<br>
Credit to CynoSure Prime for the brilliant [rlite](https://github.com/Cynosureprime/rlite) tool.

<br>
<h2>License</h2>
GPL v3.0

<br>
<br>
<h2>Free Training</h2>

[![alt text](https://in.security/wp-content/uploads/2024/10/pw101logo.jpg)](https://in.security/technical-training/password-cracking/)

We developed **Password Cracking 101+1**, freely available on our website at https://in.security/technical-training/password-cracking/ 
- 4 hours of video content split into 15 parts with hands-on challenges
- Covers basic/traditional attack techniques as well as deeper, more creative attacks (such as delimited passphrases, foreign language, emojis, non-deterministic attacks etc)
- VM to download pre-built with training challenges and answers (VirtualBox OVA format)
- Password Cracking 101+1 training channel in our Discord server to chat
  
[![Discord Banner 3](https://discord.com/api/guilds/752813804491898910/widget.png?style=banner2)](https://discord.gg/5VpwE9YJ9R)
