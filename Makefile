# $OpenBSD$

# Call unveil(2) in combination with unlink(2), chroot(2), chdir(2).
# Call realpath(3) in combination with chroot(2), chdir(2).
# Use umount(8) to check that the mountpoint leaks no vnode.
# There were vnode reference counting bugs in the kernel.

PROGS=		unveil-unlink unveil-chroot unveil-perm unveil-chdir
PROGS+=		realpath-chroot realpath-chdir
CLEANFILES=	diskimage

.PHONY: mount unconfig clean

diskimage: unconfig
	@echo '\n======== $@ ========'
	${SUDO} dd if=/dev/zero of=diskimage bs=512 count=4k
	${SUDO} vnconfig vnd0 diskimage
	${SUDO} newfs vnd0c

mount: diskimage
	@echo '\n======== $@ ========'
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} mount /dev/vnd0c /mnt/regress-unveil

unconfig:
	@echo '\n======== $@ ========'
	-${SUDO} umount -f /dev/vnd0c 2>/dev/null || true
	-${SUDO} rmdir /mnt/regress-unveil 2>/dev/null || true
	-${SUDO} vnconfig -u vnd0 2>/dev/null || true
	-${SUDO} rm -f stamp-setup

REGRESS_SETUP	=	${PROGS} mount
REGRESS_CLEANUP =	unconfig
REGRESS_TARGETS =

REGRESS_TARGETS +=	run-unlink
run-unlink:
	@echo '\n======== $@ ========'
	# unlink a file in an unveiled directory
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./unveil-unlink /mnt/regress-unveil/foo bar
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot
run-chroot:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} ./unveil-chroot /mnt/regress-unveil /
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir
run-chroot-dir:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./unveil-chroot /mnt/regress-unveil/foo /
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-unveil-dir
run-chroot-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./unveil-chroot /mnt/regress-unveil /foo
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-unveil-dir
run-chroot-dir-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo/bar
	${SUDO} ./unveil-chroot /mnt/regress-unveil/foo /bar
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-open
run-chroot-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} touch /mnt/regress-unveil/baz
	${SUDO} ./unveil-chroot /mnt/regress-unveil / /baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-open
run-chroot-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-chroot /mnt/regress-unveil/foo / /baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-unveil-dir-open
run-chroot-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-chroot /mnt/regress-unveil /foo /baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-unveil-dir-open
run-chroot-dir-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo/bar
	${SUDO} touch /mnt/regress-unveil/foo/bar/baz
	${SUDO} ./unveil-chroot /mnt/regress-unveil/foo /bar /baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm
run-perm:
	@echo '\n======== $@ ========'
	# unveil in a perm environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} ./unveil-perm "" /mnt/regress-unveil
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir
run-perm-dir:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./unveil-perm "" /mnt/regress-unveil/foo
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-open
run-perm-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} touch /mnt/regress-unveil/baz
	${SUDO} ./unveil-perm "" /mnt/regress-unveil baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir-open
run-perm-dir-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-perm "" /mnt/regress-unveil/foo baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-create-open
run-perm-create-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} touch /mnt/regress-unveil/baz
	${SUDO} ./unveil-perm "c" /mnt/regress-unveil baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir-create-open
run-perm-dir-create-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-perm "c" /mnt/regress-unveil/foo baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-write-open
run-perm-write-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} touch /mnt/regress-unveil/baz
	${SUDO} ./unveil-perm "w" /mnt/regress-unveil baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir-write-open
run-perm-dir-write-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-perm "w" /mnt/regress-unveil/foo baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir
run-chdir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} ./unveil-chdir /mnt/regress-unveil .
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir
run-chdir-dir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./unveil-chdir /mnt/regress-unveil/foo .
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-unveil-dir
run-chdir-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./unveil-chdir /mnt/regress-unveil foo
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-unveil-dir
run-chdir-dir-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo/bar
	${SUDO} ./unveil-chdir /mnt/regress-unveil/foo bar
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-open
run-chdir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} touch /mnt/regress-unveil/baz
	${SUDO} ./unveil-chdir /mnt/regress-unveil . baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-open
run-chdir-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-chdir /mnt/regress-unveil/foo  baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-unveil-dir-open
run-chdir-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} touch /mnt/regress-unveil/foo/baz
	${SUDO} ./unveil-chdir /mnt/regress-unveil foo baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-unveil-dir-open
run-chdir-dir-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo/bar
	${SUDO} touch /mnt/regress-unveil/foo/bar/baz
	${SUDO} ./unveil-chdir /mnt/regress-unveil/foo bar baz
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-realpath-chroot
run-realpath-chroot:
	@echo '\n======== $@ ========'
	# ralpath in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} ./realpath-chroot /mnt/regress-unveil /
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-realpath-chroot-dir
run-realpath-chroot-dir:
	@echo '\n======== $@ ========'
	# realpath in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./realpath-chroot /mnt/regress-unveil/foo /
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-realpath-dir
run-chroot-realpath-dir:
	@echo '\n======== $@ ========'
	# realpath in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./realpath-chroot /mnt/regress-unveil /foo
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-realpath-dir
run-chroot-dir-realpath-dir:
	@echo '\n======== $@ ========'
	# realpath in a chroot environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo/bar
	${SUDO} ./realpath-chroot /mnt/regress-unveil/foo /bar
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-realpath-chdir
run-realpath-chdir:
	@echo '\n======== $@ ========'
	# realpath in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil
	${SUDO} ./realpath-chdir /mnt/regress-unveil .
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-realpath-chdir-dir
run-realpath-chdir-dir:
	@echo '\n======== $@ ========'
	# realpath in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./realpath-chdir /mnt/regress-unveil/foo .
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-ralpath-dir
run-chdir-realpath-dir:
	@echo '\n======== $@ ========'
	# realpath in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo
	${SUDO} ./realpath-chdir /mnt/regress-unveil foo
	${SUDO} umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-realpath-dir
run-chdir-dir-realpath-dir:
	@echo '\n======== $@ ========'
	# realpath in a chdir environment
	${SUDO} mkdir -p /mnt/regress-unveil/foo/bar
	${SUDO} ./realpath-chdir /mnt/regress-unveil/foo bar
	${SUDO} umount /mnt/regress-unveil

REGRESS_ROOT_TARGETS =	${REGRESS_TARGETS}

.include <bsd.regress.mk>
