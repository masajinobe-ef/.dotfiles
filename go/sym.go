package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/fatih/color"
)

const (
	dotfilesDir = ".dotfiles"
	i3Dir       = "i3"
	airDir      = "air"
)

var (
	targetBin     = filepath.Join(os.Getenv("HOME"), ".local/bin")
	targetScripts = filepath.Join(os.Getenv("HOME"), ".local/scripts")
	targetConfig  = filepath.Join(os.Getenv("HOME"), ".config")
	targetHome    = os.Getenv("HOME")
	configDir     = filepath.Join(dotfilesDir, i3Dir, "config")
	airConfigDir  = filepath.Join(dotfilesDir, airDir, "config")
)

func exitWithError(message string) {
	color.Set(color.FgRed)
	fmt.Println("Error: " + message)
	color.Unset()
	os.Exit(1)
}

func runStowCommand(args ...string) error {
	cmd := exec.Command("stow", args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to execute stow: %s\nOutput: %s", err, string(output))
	}
	return nil
}

func createDirectory(target string) {
	if _, err := os.Stat(target); os.IsNotExist(err) {
		color.Set(color.FgYellow)
		fmt.Printf("INFO: Creating directory %s...\n", target)
		color.Unset()
		if err := os.MkdirAll(target, os.ModePerm); err != nil {
			exitWithError(fmt.Sprintf("Failed to create directory %s: %v", target, err))
		}
	} else {
		color.Set(color.FgGreen)
		fmt.Printf("INFO: Directory %s already exists.\n", target)
		color.Unset()
	}
}

func manageSymlinks(dir, target string, remove bool) {
	operation := "Creating"
	if remove {
		operation = "Removing"
	}

	color.Set(color.FgCyan)
	fmt.Printf("INFO: %s symlinks from %s to %s...\n", operation, dir, target)
	color.Unset()

	args := []string{"--dir=" + dir, "--target=" + target, filepath.Base(dir)}
	if remove {
		args = append(args, "-D")
	}

	if err := runStowCommand(args...); err != nil {
		exitWithError(err.Error())
	}

	if remove {
		color.Set(color.FgGreen)
		fmt.Printf("INFO: Symlinks successfully removed from %s to %s.\n", dir, target)
		color.Unset()
	} else {
		color.Set(color.FgGreen)
		fmt.Printf("INFO: Symlinks successfully created from %s to %s.\n", dir, target)
		color.Unset()
	}
}

func printHelp() {
	color.Set(color.FgMagenta)
	fmt.Println("Usage: go run main.go [options]")
	fmt.Println("\nOptions:")
	color.Unset()

	// Apply color to the flag descriptions
	color.Set(color.FgCyan)
	flag.PrintDefaults()
	color.Unset()
}

func main() {
	delinkMode := flag.Bool("d", false, "Remove existing symlinks")
	useAir := flag.Bool("m", false, "Use AIR directory instead of I3")
	flag.Parse()

	// Print help if -h or --help is passed
	if len(os.Args) == 1 || *flag.Bool("h", false, "Show help") {
		printHelp()
		return
	}

	// Set configDir to AIR's config directory if specified
	if *useAir {
		configDir = airConfigDir
	}

	// Directories to process
	directories := map[string]string{
		filepath.Join(dotfilesDir, i3Dir, "bin"):     targetBin,
		filepath.Join(dotfilesDir, i3Dir, "scripts"): targetScripts,
		configDir: targetConfig,
		filepath.Join(dotfilesDir, i3Dir, "home"): targetHome,
	}

	if *delinkMode {
		// Remove symlinks
		for src, dest := range directories {
			manageSymlinks(src, dest, true)
		}
		color.Set(color.FgGreen)
		fmt.Println("INFO: All symlinks successfully removed.")
		color.Unset()
	} else {
		// Create symlinks
		for src, dest := range directories {
			createDirectory(dest)
			manageSymlinks(src, dest, false)
		}
		color.Set(color.FgGreen)
		fmt.Println("INFO: All directories successfully symlinked.")
		color.Unset()
	}

	// Wait for user input to exit
	color.Set(color.FgCyan)
	fmt.Println("Press Enter to exit...")
	color.Unset()
	var input string
	fmt.Scanln(&input)
}
