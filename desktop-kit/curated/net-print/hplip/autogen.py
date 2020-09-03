#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	hplip_url = "https://sourceforge.net/projects/hplip/best_release.json"
	json_dict = await hub.pkgtools.fetch.get_page(hplip_url, is_json=True)
	release_dict = json_dict["release"]
	dist_url = "https://sourceforge.net/projects/hplip/files/hplip/{}/hplip-{}.tar.gz"
	version = re.findall(r"\d+.\d+.\d+", release_dict["url"])[0]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat="python2+",
		artifacts=[hub.pkgtools.ebuild.Artifact(url=dist_url.format(version, version))],
	)
	ebuild.push()
