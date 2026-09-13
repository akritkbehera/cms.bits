package: system-externals
version: "1"
variables:
 seeds: 'bash glibc glibc-headers openssl-libs libX11 libxcrypt readline ncurses-libs tcl tk mesa-libGLU libglvnd-glx libglvnd-opengl libXext libXft libXpm perl perl-libs libbrotli python3 perl-base perl-lib perl-filetest perl-overload perl-vars libcom_err krb5-libs libaio libgcc'
hook: disable
---
provides_arr=(
    "/bin/bash"
    "/usr/bin/bash"
    "/bin/env"
    "/bin/tcsh"
    "/bin/csh"
    "libdrm.so.2()(64bit)"
    "libdrm_amdgpu.so.1()(64bit)"
    "/usr/bin/python"
    "perl(Cwd)"
    "perl(File::Basename)"
    "perl(File::stat)"
    "perl(Getopt::Long)"
    "perl(List::Util)"
    "perl(POSIX)"
    "perl(bigint)"
    "perl(Carp)"
    "perl(Class::Struct)"
    "perl(Data::Dumper)"
    "perl(Errno)"
    "perl(Exporter)"
    "perl(File::Copy)"
    "perl(File::Find)"
    "perl(File::Path)"
    "perl(File::Spec)"
    "perl(File::Temp)"
    "perl(IO::File)"
    "perl(Text::ParseWords)"
    "perl(constant)"
    "/usr/bin/env"
    "/usr/bin/perl"
    "perl(CGI)"
    "perl(CGI::Carp)"
    "perl(CGI::Util)"
    "perl(DBI)"
    "perl(Digest::MD5)"
    "perl(Encode)"
    "perl(Fcntl)"
    "perl(Getopt::Std)"
    "perl(IO::Pipe)"
    "perl(IO::Socket)"
    "perl(IPC::Open2)"
    "perl(IPC::Open3)"
    "perl(Memoize)"
    "perl(SVN::Core)"
    "perl(SVN::Delta)"
    "perl(SVN::Ra)"
    "perl(Scalar::Util)"
    "perl(Storable)"
    "perl(Time::HiRes)"
    "perl(Time::Local)"
    "perl(YAML::Any)"
    "/bin/rc"
)

cat << 'EoF' > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
to_json() {
    sort -u | awk '
        BEGIN { printf "[" }
        { printf "%%s%%s", (NR>1 ? "," : ""), "\n  " ; gsub(/\\/,"\\\\"); gsub(/"/,"\\\""); printf "\"%%s\"", $0 }
        END { print (NR ? "\n" : "") "]" }
    '
}
EoF
{
  echo "fake_provides=\$(cat <<'FAKE_PROVIDES_EOF'"
  printf '%%s\n' "${provides_arr[@]}"
  echo "FAKE_PROVIDES_EOF"
  echo ")"
} >> "$INSTALLROOT/etc/profile.d/post-relocate.sh"

cat << EoF >> "$INSTALLROOT/etc/profile.d/post-relocate.sh"
export seeds='%(seeds)s'
seed_provides=""

for req in \$seeds; do
    if ! _rpm=\$(rpm -q --whatprovides "\$req" 2> /dev/null); then
        echo "system-externals: nothing provides '\$req' -- skipped" >&2
        continue
    fi
    _rpm=\$(printf '%%s\n' "\$_rpm" | head -n 1)
    seed_provides="\${seed_provides}
\$(rpm -q --provides "\$_rpm" 2> /dev/null || true)"
done

printf '%%s\n%%s\n' "\$seed_provides" "\$fake_provides" \
  | grep . \
  | to_json > "\$WORK_DIR/$ARCHITECTURE/system-provides.json"
EoF
