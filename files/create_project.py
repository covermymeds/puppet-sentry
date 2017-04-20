#
# This script checks to see if a project exists for the given
# app_env/team.
#
import os
import sys
from optparse import OptionParser
from urllib import quote

# Add in the sentry object models
from sentry.models import Organization, Project, ProjectKey, Team, User
from django.conf import settings

from sentry.utils.runner import configure
configure()


def build_parser():
    parser = OptionParser()
    parser.add_option("-p", "--project", dest="project", help="Application/Project name.", type="string")
    parser.add_option("-l", "--platform", dest="platform", help="Application Language/Platform.", type="string")
    parser.add_option("-o", "--org", dest="org", help="Organization to own this project", type="string")
    parser.add_option("-t", "--team", dest="team", help="Team to own this project", type="string")
    parser.add_option("-v", "--verbose", dest="verbose", help="Verbose output", action="store_true")
    parser.add_option("-s", "--sentry-path", dest="sentry_path", help="Path to sentry project", action="store_true")
    return parser


def main():
    parser = build_parser()
    options, _args = parser.parse_args()

    os.environ['SENTRY_CONF'] = options.sentry_path

    admin_email = settings.SENTRY_OPTIONS['system.admin-email']

    if not options.project:
        parser.error("Project name required")
    if not options.platform:
        parser.error("Platform is required")

    try:
        o = Organization.objects.get(name=options.org)
    except Organization.DoesNotExist:
        print "Organization not found: %s" % options.org
        sys.exit(1)

    try:
        u = User.objects.get(email=admin_email)
    except User.DoesNotExist:
        print "Admin user not found: %s" % admin_email
        sys.exit(1)

    # try to load the requested team
    try:
        t = Team.objects.get(name=options.team, organization_id=o.id)
    except Team.DoesNotExist:
        # this team does not yet exist.    Create it.
        t = Team()
        t.name = options.team
        t.organization_id = o.id
        t.owner_id = u.id
        t.save()
        # reload the object
        t = Team.objects.get(name=options.team, organization_id=o.id)

    try:
        p = Project.objects.get(name=options.project, team_id=t.id)
    except:
        # the project doesn't exist.    Create it!
        p = Project()
        # ensure all project names are in lowercase
        p.name = options.project.lower()
        p.team_id = t.id
        p.organization_id = o.id
        p.platform = options.platform

        try:
            p.save()
        except:
            print "Project save failed for %s" % (options.project)
            sys.exit(1)

    # create a static file containing this application's DSN
    k = ProjectKey.objects.get(project_id=p.id).get_dsn()
    prefix = quote(o.name.lower() + "-" + t.name.lower() + "-")
    dsn_path = "%s/dsn/%s%s" % (options.sentry_path, prefix, p.name)
    dsn = open(dsn_path, 'w')
    dsn.write(k)
    dsn.close()

    if options.verbose:
        print "Project %s created in team %s." % (options.project, t.name)


if __name__ == "__main__":
    main()
