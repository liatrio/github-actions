const version = process.argv[2]
const target = process.argv[3] || "PATCH"
const versionParts = version.match(/(\d+)\.(\d+)\.(\d+)(-\w+)?/);

switch (target.toUpperCase()) {
    case 'MAJOR':
        versionParts[1]++;
        break;
    case 'MINOR':
        versionParts[2]++;
        break;
    case 'PATCH':
        versionParts[3]++;
        break;
    default:
        console.error(`Invalid SemVer part "${target}"`);
        process.exit(1);
}

console.log(`${versionParts[1]}.${versionParts[2]}.${versionParts[3]}${versionParts[4] || ''}`);