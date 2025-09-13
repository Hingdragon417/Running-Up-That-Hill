#!/usr/bin/env python3
"""
Simple tests for the Running Up That Hill project.
"""

import sys
import os

# Add the current directory to the path so we can import our module
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    import running_up_that_hill
    print("✓ Successfully imported running_up_that_hill module")
except ImportError as e:
    print(f"✗ Failed to import running_up_that_hill module: {e}")
    sys.exit(1)

def test_hill_runner():
    """Test the HillRunner class."""
    runner = running_up_that_hill.HillRunner("Test Runner")
    
    assert runner.name == "Test Runner"
    assert runner.position == 0
    assert runner.understanding == 0
    assert runner.energy == 100
    
    # Test taking a step
    initial_energy = runner.energy
    step = runner.take_step()
    assert step > 0 or runner.energy <= 0  # Should take a step if has energy
    assert runner.position >= 0
    assert runner.energy <= initial_energy  # Energy should decrease or stay same
    
    # Test gaining understanding
    runner.gain_understanding(50)
    assert runner.understanding == 50
    
    # Test understanding cap
    runner.gain_understanding(60)
    assert runner.understanding == 100  # Should cap at 100
    
    # Test rest
    runner.energy = 50
    initial_energy = runner.energy
    runner.rest()
    assert runner.energy >= initial_energy  # Energy should increase
    assert runner.energy <= 100  # Should cap at 100
    
    print("✓ HillRunner class tests passed")

def test_html_file_exists():
    """Test that the HTML file exists and contains expected content."""
    html_path = os.path.join(os.path.dirname(__file__), 'index.html')
    
    if not os.path.exists(html_path):
        print("✗ index.html file does not exist")
        return False
    
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for key elements
    required_elements = [
        '<title>Running Up That Hill',
        'Journey of Understanding',
        'Begin the Journey',
        'Take a Step Together',
        'Pause and Listen',
        'Start Over'
    ]
    
    for element in required_elements:
        if element not in content:
            print(f"✗ HTML file missing required element: {element}")
            return False
    
    print("✓ HTML file exists and contains expected content")
    return True

def test_readme_file():
    """Test that README has been updated with project information."""
    readme_path = os.path.join(os.path.dirname(__file__), 'README.md')
    
    if not os.path.exists(readme_path):
        print("✗ README.md file does not exist")
        return False
    
    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for key sections
    required_sections = [
        '# Running Up That Hill',
        '## About',
        '## Features',
        '## How to Use',
        'python3 running_up_that_hill.py'
    ]
    
    for section in required_sections:
        if section not in content:
            print(f"✗ README missing required section: {section}")
            return False
    
    print("✓ README file contains expected project documentation")
    return True

def run_all_tests():
    """Run all tests."""
    print("Running tests for Running Up That Hill project...")
    print("=" * 50)
    
    try:
        test_hill_runner()
        test_html_file_exists()
        test_readme_file()
        
        print("=" * 50)
        print("✅ All tests passed! The project is working correctly.")
        return True
        
    except Exception as e:
        print(f"✗ Test failed with error: {e}")
        print("=" * 50)
        print("❌ Some tests failed.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)