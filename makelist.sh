#! /bin/sh
apt list --installed | grep librust- | sed "s/ arm64.*//" | sed "s:/.* :=:" | sort
