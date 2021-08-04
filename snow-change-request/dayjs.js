import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc.js';
import isSameOrBefore from 'dayjs/plugin/isSameOrBefore.js';
import isSameOrAfter from 'dayjs/plugin/isSameOrAfter.js';

[utc, isSameOrBefore, isSameOrAfter].forEach((plugin) => dayjs.extend(plugin));

export default dayjs;
