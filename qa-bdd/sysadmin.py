import os.path
import re
import shutil
import time


@given(u'instance dir does not exist')
def step_impl(context):
    print "instance dir:", context.instance_dir
    if os.path.isdir(context.instance_dir):
        shutil.rmtree(context.instance_dir)


@when(u'sysadmin applies no template')
def step_impl(context):
    print "applying no template"


@when(u'sysadmin applies template {name}')
def step_impl(context, name):
    print "applying template:", name
    context.templates[name] = {}


@when(u'sysadmin configures template {name} {prop} {value}')
def step_impl(context, name, prop, value):
    value = context.resolve_random_ports(value)
    print "configuring template %s: %s=%s" % (name, prop, value)
    context.templates[name][prop] = value


@when(u'sysadmin configures valve status_report_valve {status_code} {uri}')
def step_impl(context, status_code, uri):
    uri = context.resolve_random_ports(uri)
    print "configuring status_report_value: sc=%s, uri=%s" % \
            (status_code, uri)
    config = open(context.instance_config).read()
    if not "com.springsource.tcserver.security.StatusReportValve" in config:
        i = config.find('</Realm>') + len('</Realm>')
        out = open(context.instance_config, 'w')
        out.write(config[:i])
        out.write('\n')
        valve_config = context.template('status_report_valve.xml')
        if valve_config[-1] == '\n':
            valve_config = valve_config[:-1]
        out.write(valve_config)
        out.write(config[i:])
        out.close()
        config = open(context.instance_config).read()
        i = config.find("<Host ")
        i = config.find(">", i)
        out = open(context.instance_config, 'w')
        out.write(config[:i])
        out.write('\nerrorReportValveClass=""')
        out.write(config[i:])
        out.close()
        config = open(context.instance_config).read()
    i = config.find("com.springsource.tcserver.security.StatusReportValve")
    i = config.find("/>", i)
    out = open(context.instance_config, 'w')
    out.write(config[:i])
    out.write('\nerror.{}="{}"\n'.format(status_code, uri))
    out.write(config[i:])
    out.close()


@when(u'sysadmin reconfigures {prop} {value}')
def step_impl(context, prop, value):
    value = context.resolve_random_ports(value)
    print "reconfiguring: %s=%s" % (prop, value)
    context.set_property(context.instance_properties, prop, value)


@when(u'sysadmin creates instance')
def step_impl(context):
    print "creating instance:", context.instance_name
    context.args.insert(0, 'create')
    for name in context.templates.keys():
        context.args += ["--template", name]
        for prop, value in context.templates[name].items():
            context.args += ["--property", "%s=%s" % (prop, value)]
    context.args += ['--instance-directory', context.instance_home]
    context.args += [context.instance_name]
    context.tcruntime_instance(context.args)


@when(u'sysadmin starts instance')
def step_impl(context):
    print "starting instance:", context.instance_name
    args = ['-n', context.instance_home]
    args += [context.instance_name]
    args += ['start']
    context.tcruntime_ctl(args)
    # wait until we see message indicating we're ready
    if context.TCS_3056:
        context.set_property(context.instance_properties,
                'java.security.egd', 'file:/dev/./urandom')
    watch_for_in_file(context.instance_logfile,
            "INFO: Server startup in", context.startup_timeout)


@when(u'sysadmin stops instance')
def step_impl(context):
    if os.path.exists(context.instance_pidfile):
        print "stopping instance:", context.instance_name
        args = ['-n', context.instance_home]
        args += [context.instance_name]
        args += ['stop']
        context.tcruntime_ctl(args)
    else:
        print "instance already stopped:", context.instance_name

@when(u'sysadmin start redis')
def step_impl(context):
    if os.path.exists(context.redis_pidfile):
	print "Redis appears to be already running"
    else:
	print "starting redis server:",context.redis
	args += ['start']
	context.redis-server(args)

@when(u'sysadmin sets Java to version {version}')
def step_impl(context, version):
    print 'setting Java version to', version
    qa_jdk_home = 'QA_JDK' + version + '_HOME'
    assert os.environ.has_key(qa_jdk_home)
    os.environ['JRE_HOME'] = os.environ[qa_jdk_home]

@when(u'sysadmin sets tc Runtime to version {version}')
def step_impl(context, version):
    print 'setting tc Server version to', version
    context.args += ['--version', version]

def watch_for_in_file(path, s, maxcount):
    print "waiting up to %ss to see '%s' in %s" % (maxcount, s, path)
    r = re.compile(s)
    count = 0
    while True:
        assert count != maxcount
        count += 1
        try:
            content = open(path).read()
            if r.search(content):
                print "found"
                break
            print "not found"
        except IOError as e:
            print "error reading", path
        print "waiting (%s)" % count
        time.sleep(1)

# vim: et sw=4 sts=4
