import * as core from '@actions/core';
import dayjs from '../dayjs.js';
import * as serviceNow from '../snow.js';

export const requireChangeRequestApproval = async (inputs) => {
    if (!inputs.requestSysId) {
        throw new Error('must set requestSysId');
    }

    const snow = serviceNow.newClient(inputs);
    const response = await snow.get({
        path: `/api/sn_chg_rest/change/${inputs.requestSysId}`,
    });

    const approvalStatus = response.result?.approval?.value;
    const changeStartDate = response.result?.start_date?.value;
    const changeEndDate = response.result?.end_date?.value;

    core.info(`Change request ${inputs.requestSysId} has approval status '${approvalStatus}' and a change window between ${changeStartDate || 'unknown'} and ${changeEndDate || 'unknown'}`);
    if (approvalStatus !== 'approved') {
        core.setFailed('Change request has not been approved');
        return;
    }

    if (!(changeStartDate && changeEndDate)) {
        core.setFailed('Change request does not a have change window, cannot proceed');
        return;
    }

    const windowStart = dayjs.utc(changeStartDate);
    const windowEnd = dayjs.utc(changeEndDate);
    const now = dayjs.utc();

    const inWindow = now.isSameOrAfter(windowStart) && now.isSameOrBefore(windowEnd);
    if (!inWindow) {
        core.setFailed('The current time is not in the change window');
    }
}










