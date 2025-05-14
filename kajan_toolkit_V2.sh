#!/bin/bash
# KAJAN - Ethical Toolkit v2
# Author: Kajan Sivaraja
# For educational and legal use only

# ===== TOOL INTRODUCTION & PERMISSION =====
printf "\033[32m"
echo "██╗  ██╗ █████╗      ██╗ █████╗ ███╗   ██╗"
echo "██║ ██╔╝██╔══██╗    ██╔╝██╔══██╗████╗  ██║"
echo "█████╔╝ ███████║   ██╔╝ ███████║██╔██╗ ██║"
echo "██╔═██╗ ██╔══██║  ██╔╝  ██╔══██║██║╚██╗██║"
echo "██║  ██╗██║  ██║ ██╔╝   ██║  ██║██║ ╚████║"
echo "╚═╝  ╚═╝╚═╝  ╚═╝ ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═══╝"
echo "     💻 KAJAN - Ethical Hacking Toolkit V2 💻"
printf "\033[0m"
echo ""
echo "Welcome to the KAJAN Toolkit — a Bash-based ethical hacking tool for cybersecurity labs and education."
echo "It includes password brute-force, network scans, subdomain enumeration, intel lookups, reporting, and more."
echo "Use responsibly."
echo "-------------------------------------------------------------------------------------------------------------------"
read -p "❓ Do you have permission to perform these tests? (yes/no): " has_permission
if [[ $has_permission != "yes" ]]; then
  echo "❌ Permission not granted. Exiting the toolkit."
  exit 1
fi

# ===== Logging Setup =====
mkdir -p output
LOGFILE="output/kajan_$(date +%Y%m%d_%H%M%S).log"

# ===== Auto Update Check =====
function check_for_update() {
  latest_version=$(curl -s https://api.github.com/repos/kajan/toolkit/releases/latest | jq -r .tag_name)
  current_version="v2"  # Update this manually or dynamically

  if [[ "$latest_version" != "$current_version" ]]; then
    echo "New version available! Updating..."
    curl -LO https://github.com/kajan/toolkit/releases/download/$latest_version/kajan_toolkit_v3.sh
    chmod +x kajan_toolkit_v3.sh
  else
    echo "You're using the latest version."
  fi
}
# ===== Ask for OS Type =====
echo "Select your OS to proceed with dependency checks/installations:"
echo "1) Ubuntu/Debian"
echo "2) macOS"
echo "3) Windows (Manual Only)"
read -p "Enter your choice (1/2/3): " os_choice

# ===== Dependency Installer =====
function install_tool() {
  local tool=$1
  case $os_choice in
    1)  # Ubuntu/Debian
      echo "📦 Installing $tool via apt..."
      sudo apt update && sudo apt install -y "$tool"
      ;;
    2)  # macOS
      echo "📦 Installing $tool via Homebrew..."
      if ! command -v brew &> /dev/null; then
        printf "\033[31m❌ Homebrew is not installed. Please install it from https://brew.sh first.\033[0m\n"
        exit 1
      fi
      brew install "$tool"
      ;;
    3)  # Windows
      printf "\033[33m⚠️ Please install $tool manually on Windows.\033[0m\n"
      ;;
    *)  # Invalid OS choice
      printf "\033[31m❌ Invalid OS choice. Exiting.\033[0m\n"
      exit 1
      ;;
  esac
}

# ===== Check Dependency =====
function check_dependency() {
  local tool=$1
  if ! command -v "$tool" &> /dev/null; then
    printf "\033[33m $tool not found.\033[0m\n"
    read -p " Do you want to install $tool? (yes/no): " answer
    if [[ $answer == "yes" ]]; then
      install_tool "$tool"
    else
      printf "\033[31m $tool is required. Exiting.\033[0m\n"
      exit 1
    fi
  fi
}

# ===== Final Exit Prompt =====
function ask_exit_permission() {
  echo
  read -p "Do you want to close KAJAN Toolkit now? (yes/no): " close_ans
  if [[ $close_ans != "yes" ]]; then
    echo " Restarting script..."
    exec "$0"
  else
    echo "Bye! Stay legal."
    exit 0
  fi
}

# ===== Feature Output Wrapper =====
function log_and_display() {
  echo -e "\n\033[34m[+] $1\033[0m" | tee -a "$LOGFILE"
  eval "$2" 2>&1 | tee -a "$LOGFILE"
}

# ===== Input Sanitization for Security =====
function sanitize_input() {
  local input=$1
  # Remove any special characters to avoid command injection risks
  input=$(echo "$input" | sed 's/[^a-zA-Z0-9.-]//g')
  echo "$input"
}

# ===== SSH Brute-force =====
function ssh_brute_force() {
  check_dependency hydra
  read -p " Enter Target IP: " TARGET
  TARGET=$(sanitize_input "$TARGET")
  read -p " Enter Username: " USER
  USER=$(sanitize_input "$USER")
  WORDLIST="/usr/share/wordlists/rockyou.txt"
  if [ ! -f "$WORDLIST" ]; then
    read -p "👉 Enter custom wordlist path: " WORDLIST
  fi
  log_and_display "SSH Brute-force on $TARGET" "hydra -l $USER -P $WORDLIST ssh://$TARGET"
}

# ===== Nmap Scan =====
function run_nmap() {
  check_dependency nmap
  read -p " Enter target IP/domain: " TARGET
  TARGET=$(sanitize_input "$TARGET")
  log_and_display "Nmap Scan on $TARGET" "nmap -sV $TARGET"
}

# ===== Whois Lookup =====
function run_whois() {
  check_dependency whois
  read -p " Enter domain: " DOMAIN
  DOMAIN=$(sanitize_input "$DOMAIN")
  log_and_display "Whois Lookup for $DOMAIN" "whois $DOMAIN"
}

# ===== Subdomain Enum =====
function subdomain_enum() {
  check_dependency sublist3r
  read -p " Enter domain: " DOMAIN
  DOMAIN=$(sanitize_input "$DOMAIN")
  log_and_display "Subdomain Enumeration for $DOMAIN" "sublist3r -d $DOMAIN"
}

# ===== Public IP =====
function check_public_ip() {
  log_and_display "Checking Public IP" "curl -s ifconfig.me"
}

# ===== Hash Cracker =====
function hash_cracker() {
  check_dependency john
  read -p " Enter hash file path: " HASHFILE
  HASHFILE=$(sanitize_input "$HASHFILE")
  if [[ ! -f "$HASHFILE" ]]; then
    echo " Hash file not found."
    return
  fi
  log_and_display "Hash Cracking on $HASHFILE" "john --wordlist=/usr/share/wordlists/rockyou.txt $HASHFILE"
}

# ===== Threat Intel =====
function threat_lookup() {
  read -p "📌 Enter IP address to lookup: " IP
  IP=$(sanitize_input "$IP")
  log_and_display "Threat Intel Lookup for $IP" "curl -G https://api.abuseipdb.com/api/v2/check --data-urlencode ipAddress=$IP -H 'Key: YOUR_API_KEY' -H 'Accept: application/json'"
}

# ===== Summary Report =====
function generate_report() {
  echo -e "\n--- KAJAN REPORT ---\nTool run at: $(date)" | tee -a "$LOGFILE"
  cat "$LOGFILE" | tee output/summary.txt
  if command -v pandoc &> /dev/null; then
    pandoc output/summary.txt -o output/summary.pdf
    echo " PDF report saved to output/summary.pdf"
  fi
}

# ===== Pentest Mode =====
function run_pentest_mode() {
  run_nmap
  run_whois
  check_public_ip
  generate_report
}

# ===== CLI MENU =====
echo "1 SSH Password Guess (Hydra)"
echo "2  Nmap Scan"
echo "3  Whois Lookup"
echo "4  Subdomain Enumeration"
echo "5  Public IP Checker"
echo "6  Hash Cracker (John)"
echo "7  Threat Intel Lookup (AbuseIPDB)"
echo "8  Generate Summary Report"
echo "8  Run Pentest Mode (Auto)"
echo "10 Exit"
read -p "👉 Enter your choice: " choice

# ===== Execute Menu Choice =====
case $choice in
  1) ssh_brute_force ;;
  2) run_nmap ;;
  3) run_whois ;;
  4) subdomain_enum ;;
  5) check_public_ip ;;
  6) hash_cracker ;;
  7) threat_lookup ;;
  8) generate_report ;;
  9) run_pentest_mode ;;
  10) echo "👋 Bye! Stay legal." && exit 0 ;;
  *) echo "❌ Invalid choice." ;;
esac

# ===== Ask Before Exit =====
ask_exit_permission
