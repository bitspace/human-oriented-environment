#!/usr/bin/env python3
"""
Comprehensive System Update Script
Handles multiple package managers and development tools with robust error handling
"""

import json
import logging
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Configuration
LOG_DIR = Path.home() / ".local" / "share" / "update-logs"
LOG_FILE = LOG_DIR / f"update-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
TIMEOUT = 300  # 5 minutes per operation

class UpdateManager:
    def __init__(self, dry_run: bool = False, verbose: bool = False):
        self.dry_run = dry_run
        self.verbose = verbose
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "dry_run": dry_run,
            "operations": [],
            "summary": {"total": 0, "successful": 0, "failed": 0, "skipped": 0}
        }
        
        # Setup logging
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        logging.basicConfig(
            level=logging.INFO if verbose else logging.WARNING,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)

    def run_command(self, cmd: List[str], description: str, 
                   check_command: Optional[List[str]] = None) -> Tuple[bool, str, str]:
        """Run a command with timeout and error handling"""
        
        # Check if the tool is available
        if check_command:
            try:
                subprocess.run(check_command, capture_output=True, timeout=10)
            except (subprocess.TimeoutExpired, FileNotFoundError):
                return False, "", f"Tool not available: {check_command[0]}"
        
        # Handle command display for logging - preserve quotes for bash -c
        if len(cmd) >= 3 and cmd[0] == "bash" and cmd[1] == "-c":
            command_display = f"bash -c '{cmd[2]}'"
        else:
            command_display = " ".join(cmd)
        
        operation = {
            "description": description,
            "command": command_display,
            "start_time": datetime.now().isoformat(),
            "success": False,
            "stdout": "",
            "stderr": "",
            "duration": 0
        }
        
        if self.dry_run:
            operation["success"] = True
            operation["stdout"] = f"DRY RUN: Would execute: {command_display}"
            self.results["operations"].append(operation)
            self.results["summary"]["skipped"] += 1
            return True, operation["stdout"], ""
        
        start_time = time.time()
        
        try:
            if self.verbose:
                self.logger.info(f"Running: {description}")
                
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=TIMEOUT
            )
            
            operation["duration"] = time.time() - start_time
            operation["stdout"] = result.stdout
            operation["stderr"] = result.stderr
            operation["return_code"] = result.returncode
            operation["success"] = result.returncode == 0
            
            if result.returncode == 0:
                self.results["summary"]["successful"] += 1
                if self.verbose:
                    self.logger.info(f"✓ {description}")
            else:
                self.results["summary"]["failed"] += 1
                self.logger.error(f"✗ {description}: {result.stderr}")
                
        except subprocess.TimeoutExpired:
            operation["duration"] = TIMEOUT
            operation["stderr"] = f"Command timed out after {TIMEOUT} seconds"
            operation["success"] = False
            self.results["summary"]["failed"] += 1
            self.logger.error(f"✗ {description}: Timeout")
            
        except Exception as e:
            operation["duration"] = time.time() - start_time
            operation["stderr"] = str(e)
            operation["success"] = False
            self.results["summary"]["failed"] += 1
            self.logger.error(f"✗ {description}: {e}")
        
        self.results["operations"].append(operation)
        self.results["summary"]["total"] += 1
        
        return operation["success"], operation["stdout"], operation["stderr"]

    def update_arch_packages(self):
        """Update Arch Linux packages via paru"""
        self.logger.info("=== Updating Arch packages ===")
        
        # Update package databases first
        success, stdout, stderr = self.run_command(
            ["paru", "-Sy"],
            "Update package databases",
            ["paru", "--version"]
        )
        
        if not success:
            return False
            
        # Update system packages
        success, stdout, stderr = self.run_command(
            ["paru", "-Su", "--noconfirm"],
            "Update Arch packages"
        )
        
        return success

    def update_aur_packages(self):
        """Update AUR packages"""
        self.logger.info("=== Updating AUR packages ===")
        
        success, stdout, stderr = self.run_command(
            ["paru", "-Sua", "--noconfirm"],
            "Update AUR packages",
            ["paru", "--version"]
        )
        
        return success

    def update_rust_toolchain(self):
        """Update Rust toolchain and installed binaries"""
        self.logger.info("=== Updating Rust ecosystem ===")
        
        # Update rustup
        success1, stdout, stderr = self.run_command(
            ["rustup", "update"],
            "Update Rust toolchain",
            ["rustup", "--version"]
        )
        
        # Update cargo binaries
        success2, stdout, stderr = self.run_command(
            ["cargo", "install-update", "-a"],
            "Update Cargo binaries",
            ["cargo", "install-update", "--help"]
        )
        
        return success1 and success2

    def update_sdkman(self):
        """Update SDKMAN and managed SDKs"""
        self.logger.info("=== Updating SDKMAN ecosystem ===")
        
        # Note: SDKMAN commands need to be sourced, so we use bash -c
        sdkman_init_path = str(Path.home() / ".sdkman" / "bin" / "sdkman-init.sh")
        
        # Update SDKMAN itself
        selfupdate_cmd = f"source {sdkman_init_path} && sdk selfupdate"
        success1, stdout, stderr = self.run_command(
            ["bash", "-c", selfupdate_cmd],
            "Update SDKMAN",
            ["bash", "-c", f"source {sdkman_init_path} && sdk version"]
        )
        
        # Update available candidates
        update_cmd = f"source {sdkman_init_path} && sdk update"
        success2, stdout, stderr = self.run_command(
            ["bash", "-c", update_cmd],
            "Update SDKMAN candidate lists"
        )
        
        return success1 and success2

    def update_nodejs(self):
        """Update Node.js global packages"""
        self.logger.info("=== Updating Node.js ecosystem ===")
        
        # Update npm itself first
        success1, stdout, stderr = self.run_command(
            ["npm", "update", "-g", "npm"],
            "Update npm",
            ["npm", "--version"]
        )
        
        # Update all global packages
        success2, stdout, stderr = self.run_command(
            ["npm", "update", "-g"],
            "Update Node.js global packages"
        )
        
        return success1 and success2

    def update_python_packages(self):
        """Update Python packages via uv"""
        self.logger.info("=== Updating Python ecosystem ===")
        
        # Update uv itself
        success1, stdout, stderr = self.run_command(
            ["uv", "self", "update"],
            "Update uv package manager",
            ["uv", "--version"]
        )
        
        # Update uv tools
        success2, stdout, stderr = self.run_command(
            ["uv", "tool", "upgrade", "--all"],
            "Update uv-managed tools"
        )
        
        return success1 and success2

    def update_ollama_models(self):
        """Update local LLM models"""
        self.logger.info("=== Updating Ollama models ===")
        
        # Get list of installed models
        success, stdout, stderr = self.run_command(
            ["ollama", "list"],
            "List Ollama models",
            ["ollama", "--version"]
        )
        
        if not success:
            return False
            
        # Parse model list and update each
        models = []
        for line in stdout.strip().split('\n')[1:]:  # Skip header
            if line.strip():
                model_name = line.split()[0]
                if model_name != "NAME":  # Skip header if it appears
                    models.append(model_name)
        
        all_success = True
        for model in models:
            success, stdout, stderr = self.run_command(
                ["ollama", "pull", model],
                f"Update model: {model}"
            )
            all_success = all_success and success
            
        return all_success


    def cleanup_system(self):
        """Clean up package caches and orphaned packages"""
        self.logger.info("=== System cleanup ===")
        
        # Clean package cache
        success1, stdout, stderr = self.run_command(
            ["paru", "-Sc", "--noconfirm"],
            "Clean package cache"
        )
        
        # Remove orphaned packages
        success2, stdout, stderr = self.run_command(
            ["paru", "-Rns", "$(paru -Qtdq)", "--noconfirm"],
            "Remove orphaned packages"
        )
        
        return success1  # success2 might fail if no orphans exist

    def run_all_updates(self):
        """Run all update operations"""
        self.logger.info("Starting comprehensive system update")
        
        update_operations = [
            ("Arch packages", self.update_arch_packages),
            ("AUR packages", self.update_aur_packages),
            ("Rust ecosystem", self.update_rust_toolchain),
            ("SDKMAN ecosystem", self.update_sdkman),
            ("Node.js ecosystem", self.update_nodejs),
            ("Python ecosystem", self.update_python_packages),
            ("Ollama models", self.update_ollama_models),
            ("System cleanup", self.cleanup_system),
        ]
        
        for name, operation in update_operations:
            try:
                if self.verbose:
                    print(f"\n{'='*50}")
                    print(f"Updating: {name}")
                    print('='*50)
                    
                operation()
                
            except KeyboardInterrupt:
                self.logger.warning(f"Update interrupted during: {name}")
                break
            except Exception as e:
                self.logger.error(f"Unexpected error in {name}: {e}")
                continue

    def save_results(self):
        """Save results to JSON log file"""
        self.results["end_time"] = datetime.now().isoformat()
        self.results["duration"] = (
            datetime.fromisoformat(self.results["end_time"]) - 
            datetime.fromisoformat(self.results["timestamp"])
        ).total_seconds()
        
        with open(LOG_FILE, 'w') as f:
            json.dump(self.results, f, indent=2)
            
        if self.verbose:
            print(f"\nResults saved to: {LOG_FILE}")

    def print_summary(self):
        """Print human-readable summary"""
        summary = self.results["summary"]
        print(f"\n{'='*50}")
        print("UPDATE SUMMARY")
        print('='*50)
        print(f"Total operations: {summary['total']}")
        print(f"Successful: {summary['successful']}")
        print(f"Failed: {summary['failed']}")
        print(f"Skipped: {summary['skipped']}")
        
        if summary['failed'] > 0:
            print(f"\nFailed operations:")
            for op in self.results["operations"]:
                if not op["success"]:
                    print(f"  ✗ {op['description']}: {op['stderr']}")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Comprehensive system update script")
    parser.add_argument("--dry-run", action="store_true", 
                       help="Show what would be updated without making changes")
    parser.add_argument("--verbose", "-v", action="store_true",
                       help="Verbose output")
    parser.add_argument("--log-only", action="store_true",
                       help="Only generate logs, don't print summary")
    
    args = parser.parse_args()
    
    if args.dry_run:
        print("DRY RUN MODE - No changes will be made")
        print("="*50)
    
    updater = UpdateManager(dry_run=args.dry_run, verbose=args.verbose)
    
    try:
        updater.run_all_updates()
    except KeyboardInterrupt:
        print("\nUpdate interrupted by user")
        sys.exit(1)
    finally:
        updater.save_results()
        if not args.log_only:
            updater.print_summary()

if __name__ == "__main__":
    main()