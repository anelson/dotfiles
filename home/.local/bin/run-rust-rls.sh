#!/bin/bash
#
# Wrapper script to run the rust language server, ensuring that the correct version is run.
#
# Usually I want the stable toolchain and the stable RLS.
#
# But sometimes I have projects using nightly and in that case I want to use nightly RLS.
#
# But sometimes nightly is broken, so I use some slightly-older archived version of nightly, and its RLS
#
# In that case I use `rustup override set (toolchain)` in the directory of a project to force a specific roolchain.
#
# This script runs the RLS corresponding to the overridden toolchain of the current directory, if applicable, otherwise
# it runs the stable RLS.

toolchain=$(rustup show active-toolchain | cut -f1 -d " ")
rustup run $toolchain rls

# TODO: This code below will use the Rust Analyzer instead of RLS.  Analyzer is
# the way forward for IDE-like support in Rust, but it's not ready for prime
# time yet.
#rust_analyzer_path="$HOME/.local/bin/rls-lsp-server"
#
## TODO: update this as there are frequent new releases
#rust_analyzer_url="https://github.com/rust-analyzer/rust-analyzer/releases/download/2020-02-11/ra_lsp_server-linux"
#
#if [ ! -e $rust_analyzer_path ]; then
#   curl --silent -L -o $rust_analyzer_path $rust_analyzer_url
#   chmod +x $rust_analyzer_path
#fi
#
#$rust_analyzer_path
#
